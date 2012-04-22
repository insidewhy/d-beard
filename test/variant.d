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

    // alias Variant!(void, float, int, string, S) var2_t;
    // var2_t ov1;
    return 0;
}
