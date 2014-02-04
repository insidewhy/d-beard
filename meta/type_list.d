module beard.meta.type_list;

public import std.typetuple : TypeTuple, staticIndexOf;

/// like TupleList but packs everything into one type
template TL(T...) {
    alias TypeTuple!T types;

    template append(U...) {
        alias TL!(T, U) append;
    }

    template contains(U) {
        enum contains = indexOf!U != -1;
    }

    template indexOf(U) {
        enum indexOf = staticIndexOf!(U, T);
    }
}
// vim:ts=4 sw=4
