module beard.meta.find;
public import beard.meta.type_list : TL;
public import beard.meta.inverse : inverse;

// Returns the first type for which C!T returns true, else return void.
template find(alias C, T...) {
    static if (! T.length)
        alias void find;
    else static if (C!(T[0]))
        alias T[0] find;
    else
        alias find!(C, T[1..$]) find;
}

private template findAllHelper(alias C, alias R, T...) {
    static if (! T.length)
        alias R.types findAllHelper;
    else static if (C!(T[0]))
        alias findAllHelper!(C, R.append!(T[0]), T[1..$]) findAllHelper;
    else
        alias findAllHelper!(C, R, T[1..$]) findAllHelper;
}

// Return all the types for which C!T returns true.
template findAll(alias C, T...) {
    alias findAllHelper!(C, TL!(), T) findAll;
}

// Return all the types for which C!T returns false.
template filter(alias C, T...) {
    alias findAllHelper!(inverse!C, TL!(), T) filter;
}
