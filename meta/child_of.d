module beard.meta.child_of;

template ChildOf(C, P) {
    static if (is(C Unused : P))
        enum ChildOf = true;
    else
        enum ChildOf = false;
}

template ChildOf(P) {
    template Eval(C) {
        enum Eval = ChildOf!(C, P);
    }
}
