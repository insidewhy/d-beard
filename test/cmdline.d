import beard.cmdline;
import beard.io;
import std.typecons : Tuple;

int main() {
    Tuple!(bool, bool) opts;

    auto optParser = new beard.cmdline.Parser;
    optParser.banner("usage: test [options] {extra}")
        ("d,dump", &opts[0], "dump ast after parsing")
        ("v", &opts[1], "increase verbosity")
        ;

    auto args = [ "friend", "-v", "hello" ];

    optParser.parse(&args);
    println("args: ", args);
    println("opts: ", opts);

    return 0;
}
