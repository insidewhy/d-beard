module beard.meta.find;

// Returns the first type for which C!T returns true, else return void.
template find(alias C, T...) {
    static if (! T.length)
        alias void find;
    else static if (C!(T[0]))
        alias T[0] find;
    else
        alias find!(C, T[1..$]) find;
}
