module beard.variant;

import beard.meta.fold_left : foldLeft2;
import beard.meta.contains : contains;
import beard.meta.child_of : ChildOf;
import beard.io;
import std.c.string : memcpy;
import std.typetuple : staticIndexOf, allSatisfy;
import std.traits : Unqual;

private template maxSize(size_t _size) {
    enum size = _size;
    template add(U) {
        alias maxSize!(_size > U.sizeof ? _size : U.sizeof) add;
    }
}

class BadVariantCopy : Throwable {
    this(string error) { super(error); }
}

// may store any of T or be empty.
// I would prefer only allowing empty if void is in T and creating an object
// of the first type when default initialising.
// Unfortunately D does not allow default constructors for structs :(
struct Variant(T...) {
    alias T          types;
    enum size =      foldLeft2!(maxSize!0u, T).size;
    enum n_types =   T.length;

    void opAssign(U)(auto ref U rhs) {
        static if (contains!(U, T)) {
            // copying object references like this is okay
            static if (is(T == class) && is(T == shared))
                memcpy(&value_, cast(const(void*)) &rhs, rhs.sizeof);
            else
                memcpy(&value_, &rhs, rhs.sizeof);
            idx_ = staticIndexOf!(U, T);
        }
        else static if (is(U == Variant)) {
            this.value_ = rhs.value_;
            this.idx_ = rhs.idx_;
        }
        else static if (isVariant!U) {
            struct copyVariant {
                void opCall(T)(T t) {
                    static if (contains!(T, types))
                        *dest = t;
                    else throw new BadVariantCopy(
                        "cannot store type source variant holds");
                }

                void empty() { dest.reset(); }

                this(Variant *v) { dest = v; }
                Variant *dest;
            }

            rhs.apply(copyVariant(&this));
        }
        else static assert(false, "invalid variant type");
    }

    void printTo(S)(int indent, S stream) {
        struct variantPrint {
            void opCall(T)(T t) { printIndented(stream_, indent_, t); }
            void empty() { printIndented(stream_, indent_, "<empty>"); }

            this(S s, int indent) { stream_ = s; indent_ = indent; }
            S stream_;
            int indent_;
        }

        apply(variantPrint(stream, indent));
    }

    // helper for creating forwarding array mixins
    private static string makeFwd(uint idx)() {
        static if (idx < T.length + 1)
            return (idx ? "," : "[") ~
                    "&fwd!" ~ idx.stringof ~ makeFwd!(idx + 1);
        else
            return "]";
    }

    private auto applyStruct(F)(ref F f) {
        alias typeof(f.opCall(T[0])) return_type;

        static return_type fwd(uint i)(ref Variant t, ref F f) {
            static if (i < T.length)
                return f.opCall(t.as!(T[i])());
            else
                return f.empty();
        }

        static return_type function(ref Variant, ref F)[T.length + 1] forwarders =
            mixin(makeFwd!0());

        return forwarders[this.idx_](this, f);
    }

    private static auto callMatching(A, F...)(auto ref A a, F f) {
        // TODO: use something other than compiles which can
        //       hide genuine errors
        static if (! F.length) {
            static assert(false, "no matching function");
        }
        else static if (__traits(compiles, f[0](a))) {
            return f[0](a);
        }
        else static if (__traits(compiles, f[0].opCall(a))) {
            return f[0].opCall(a);
        }
        else {
            return callMatching(a, f[1..$]);
        }
    }

    private static auto callEmpty(F...)(F f) {
        static if (! F.length) {
            static assert(false, "no matching function for empty");
        }
        else static if (__traits(compiles, f[0]())) {
            return f[0]();
        }
        else static if (__traits(compiles, f[0].empty())) {
            return f[0].empty();
        }
        else {
            return callEmpty(f[1..$]);
        }
    }

    private class None {};
    private template GetReturnType(T) {
        static if(is(T return_type == return))
            alias return_type GetReturnType;
        // static else if(__traits(compiles, T(...))
        //     alias ... GetReturnType;
        else
            alias None GetReturnType;
    }

    // Helper for apply when using many function parameters.
    private auto applyFunctions(F...)(F f) {
        alias GetReturnType!(F[0]) return_type;
        static if(! is(return_type : None)) {
            static return_type fwd(uint i)(ref Variant t, F f) {
                static if (i < T.length) {
                    alias T[i] ArgType;
                    return callMatching(t.as!ArgType, f);
                }
                else
                    return callEmpty(f);
            }

            static return_type function(ref Variant, F)[T.length + 1] forwarders =
                mixin(makeFwd!0());

            return forwarders[this.idx_](this, f);
        }
        else {
            static assert(false, "incorrect arguments");
        }
    }

    // This calls directly through a compile time constructed vtable.
    // See the examples in test/variant.d, it's not as complicated as
    // it seems.
    auto apply(F...)(auto ref F f) {
        static if (F.length == 1 && __traits(hasMember, f[0], "opCall"))
            return applyStruct(f[0]);
        else
            return applyFunctions(f);
    }

    // Unsafe cast to a value, use apply to do this safely.
    ref T as(T)() { return * cast(T*) &value_; }

    // If U is a base class of all possible storable types, then return
    // it. If the variant is empty the reference this returns will be garbage.
    ref U base(U)() {
        static assert(allSatisfy!(ChildOf!U.Eval, types),
                      "not a common base class");
        return as!U;
    }

    // Test if the variant is currently storing type U directly (not via
    // superclass relationship).
    bool isType(U)() {
        static if (contains!(U, types))
            return idx_ == staticIndexOf!(U, types);
        else
            static assert(false, "type not in variant");
    }

    // Test if the variant is empty.
    bool empty() @property const { return idx_ >= T.length; }

    // Make variant empty.
    void reset() {
        // run destructor on existing class?
        idx_ = n_types;
    }

    ////////////////////////////////////////////////////////////////////////
    this(U)(U rhs) { this = rhs; }

  private:
    union {
        ubyte[size] value_;
        // mark the region as a pointer to stop objects being garbage collected
        static if (size >= (void*).sizeof)
            void* p[size / (void*).sizeof];
    }

    uint idx_ = n_types;
}

template isVariant(T) {
    // d won't allow enum isVariant = is(...);
    static if (is(Unqual!T Unused : Variant!U, U...))
        enum isVariant = true;
    else
        enum isVariant = false;
}
// vim:ts=4 sw=4
