module beard.meta.base_of;

template BaseOf(P, C) {
    static if (is(C Unused : P))
        enum BaseOf = true;
    else
        enum BaseOf = false;
}

template BaseOf(C) {
    template Eval(P) {
        enum Eval = BaseOf!(P, C);
    }
}

