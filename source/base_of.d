module beard.base_of;

/// Tests if P is a superclass of C.
template BaseOf(P, C) {
    static if (is(C Unused : P))
        enum BaseOf = true;
    else
        enum BaseOf = false;
}

/// Defines a nested Eval!C template that tests if P is a superclass of C.
template BaseOf(C) {
    template Eval(P) {
        enum Eval = BaseOf!(P, C);
    }
}

// vim:ts=4 sw=4
