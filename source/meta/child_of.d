module beard.meta.child_of;

/// Tests if C is a subclass of P.
template ChildOf(C, P) {
    static if (is(C Unused : P))
        enum ChildOf = true;
    else
        enum ChildOf = false;
}

/// Defines a nested Eval!C template that tests if C is a subclass of P.
template ChildOf(P) {
    template Eval(C) {
        enum Eval = ChildOf!(C, P);
    }
}
// vim:ts=4 sw=4
