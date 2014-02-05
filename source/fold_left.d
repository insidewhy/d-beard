module beard.fold_left;

/// Produces F(Tn, F(.., F(T2, F(A, T1))))
template foldLeft(alias F, alias A) {
    alias A foldLeft;
}

/// ditto
template foldLeft(alias F, alias A, H, T...) {
    alias foldLeft!(F, F!(A, H), T) foldLeft;
}

/// Like foldLeft but calls an inner template "add" on the first alias
/// as template argument allowing the calling template to store state.
template foldLeft2(alias F, T...) {
    alias foldLeft!(innerFold, F, T) foldLeft2;
}

/// Helper function.
private template innerFold(alias T, U) {
    alias T.add!U innerFold;
}
// vim:ts=4 sw=4
