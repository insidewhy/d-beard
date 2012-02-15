module beard.cmdline;

import beard.io;
import beard.vector : Vector, pushBack;

import std.array : split;

class CmdLineError : Throwable {
    this(string error) { super(error); }
}

class BadCommandLineArgument : CmdLineError {
    this(string error) { super(error); }
}

class UnknownCommandLineArgument : CmdLineError {
    this(string error) { super(error); }
}

class BadCommandLineArgumentValue : CmdLineError {
    this(string error) { super(error); }
}

class Parser {
    struct State {
        this(string[] *_args) { args = _args; }

        bool empty() { return argIdx >= args.length; }
        ref string front() { return (*args)[argIdx]; }

        char firstChar() { return front()[argOffset]; }
        char charAt(int idx) { return front()[argOffset + idx]; }

        void advanceOffset(int incr) {
            argOffset += incr;
            if (argOffset >= front().length) {
                argOffset = 0;
                popArgument();
            }
        }

        // advance pointer, keeping argument in args
        void saveArgument() {
            if (nextSaveIdx < argIdx)
                (*args)[nextSaveIdx] = (*args)[argIdx];
            nextSaveIdx += 1;

            popArgument();
        }

        void popArgument() { argIdx += 1; }

        string[] *args;
        // which argument currently looking at
        int       argIdx = 1;
        // offset used to keep track of where parser is within current option
        int       argOffset = 0;
        // idx where last saved argument was
        int       nextSaveIdx = 1;
    }

    class AbstractValue {
        bool parse(ref State state) { return false; }
    }

    class Value(T) : AbstractValue {
        this(T *ptr) { valPtr_ = ptr; }

        bool parse(ref State state) {
            static if (is(T : bool)) {
                *valPtr_ = true;
                state.advanceOffset(1);
                return true;
            }
            else {
            }
        }

        T* valPtr_;
    }

    struct Help {
        this(string _help) { help = _help; }
        string help;
        string[] args;
    }

    ref Parser opCall(T)(string args, T *storage, string helpString) {
        auto vals = split(args, ",");
        auto optValue = new Value!T(storage);
        auto help = Help(helpString);

        foreach (val ; vals) {
            pushBack(help.args, val);
            optionMap_[val] = optValue;
        }

        pushBack(helps_, help);

        return this;
    }

    ref Parser banner(string banner) {
        banner_ = banner;
        return this;
    }

    void parse(string[] *args) {
        auto state = State(args);

        while (! state.empty) {
            if ('-' != state.firstChar) {
                state.saveArgument;
                continue;
            }

            auto front = state.front;
            if (1 == front.length)
                throw new BadCommandLineArgument(front);
            
            if ('-' == state.charAt(1)) {
                if (2 == front.length) {
                    state.popArgument;
                    while (! state.empty)
                        state.saveArgument;
                    break;
                }

                // parse long option
                state.popArgument;
            }
            else {
                // parse short option.. maybe more than one
                state.advanceOffset(1);
                do {
                    string search = "" ~ state.firstChar;

                    auto value = optionMap_.get(search, null);
                    if (! value)
                        throw new UnknownCommandLineArgument(front);

                    if (! value.parse(state))
                        throw new BadCommandLineArgumentValue(front);
                } while (state.argOffset);
            }
        }

        args.length = state.nextSaveIdx;
    }

    void showHelp() {
        if (banner_.length)
            println(banner_);

        foreach (help ; helps_) {
        }
    }

  private:
    AbstractValue[string] optionMap_;
    Help[]                helps_;
    string                banner_;
}
