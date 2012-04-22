module beard.test.variant;

import beard.variant;
import beard.io;

class S {
    string x, y;

    this(string _x, string _y) { x = _x; y = _y; }

    string toString() {
        return "" ~ x ~ ", " ~ y;
    }
}

class Parent {
    this(string s) { s_ = s; }
    string s_;
}
class Child1 : Parent { this(string s) { super("child1: " ~ s); } }
class Child2 : Parent { this(string s) { super("child2: " ~ s); } }

struct Applier {
    string opCall(int v) { println("int:", v); return "int"; }
    string opCall(float v) { println("float:", v); return "float"; }
    string empty() { println("empty"); return "empty"; }
}

int main() {
    alias Variant!(float, int, string, S) var1_t;

    auto def = var1_t();
    println(def);

    auto v1 = var1_t(123);
    println(v1);

    auto v2 = var1_t("booby");
    println(v2);

    auto v3 = var1_t(new S("11!", "2 friend"));
    println(v3);

    v3 = S.init;
    println(v3);

    auto v4 = Variant!(float)();
    println(v4);
    v4 = 1.2f;
    println(v4);

    alias Variant!(float, int, string) src_t;
    alias Variant!(float, int) dest_t;
    auto src = src_t();
    auto dest = dest_t();
    dest.apply(
        (int v) { println("into:", v); },
        (float v) { println("floato:", v); },
        () { println("empty"); }
    );

    src = 4;
    println(src.isType!float);
    println(src.isType!int);
    dest = src;
    println(dest);

    Applier app;
    println("friend:", dest.apply(app));
    dest = 4.4f;
    println("friend:", dest.apply(app));

    println(dest.apply(
        (float v) { println("floator:", v); return "floator"; },
        (int v) { println("intor:", v); return "intor"; },
        () { println("empty"); return "empty"; }
    ));

    dest = 6;
    dest.apply(
        (int v) { println("into:", v); },
        (float v) { println("floato:", v); },
        () { println("empty"); }
    );

    auto vc = Variant!(Child1,Child2)();
    vc = new Child2("baby");
    vc.apply(
        (Parent p) { println("parent-", p.s_); },
        // the next can't be reached as Parent will always match first. Even
        // though the method lookup is done in a single step without iterating
        // through all possible functions and testing.. it still targets the
        // earliest match
        (Child2 c) { println("can never be reached:", c.s_); },
        () { println("empty"); }
    );

    // now it'll work :)
    vc.apply(
        (Child2 c) { println("child-", c.s_); },
        (Parent p) { println("parent-", p.s_); },
        () { println("empty"); }
    );

    return 0;
}
