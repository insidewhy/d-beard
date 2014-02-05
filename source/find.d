module beard.find;
public import beard.type_list : TL;
public import beard.fold_left : foldLeft;
public import beard.inverse : inverse;

/// Returns the first type for which C!T returns true, else return void.
template find(alias C, T...) {
    static if (! T.length)
        alias void find;
    else static if (C!(T[0]))
        alias T[0] find;
    else
        alias find!(C, T[1..$]) find;
}

/// Return all the types for which C!T returns true.
template findAll(alias C, T...) {
    template fold(alias R, U) {
        static if (C!U)
            alias R.append!U fold;
        else
            alias R fold;
    }

    alias foldLeft!(fold, TL!(), T).types findAll;
}

/// Return all the types for which C!T returns false.
template filter(alias C, T...) {
    alias findAll!(inverse!C, T) filter;
}
// vim:ts=4 sw=4
