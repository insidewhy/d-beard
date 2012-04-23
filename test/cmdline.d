import beard.cmdline;
import beard.io;
import std.typecons : Tuple;

int main() {
    Tuple!(bool, bool, bool, string, string[]) opts;

    auto optParser = new beard.cmdline.Parser;
    optParser.banner("usage: test [options] {extra}")
        ("d,dump", &opts[1], "dump on faces")
        ("v", &opts[2], "increase verbosity")
        ("s,strong", &opts[3], "here is my face")
        ("I,include", &opts[4], "your friend basher")
        ;

    auto args = [
        "friend", "-Ibeast", "-vs", "poodar", "-dIfriend", "--include", "ear",
        "hello" ];

    optParser.parse(&args);
    println("args: ", args);
    println("opts: ", opts);

    args = [ "friend", "--help" ];
    optParser.parse(&args);
    println("shown help: ", optParser.shownHelp);

    return 0;
}
