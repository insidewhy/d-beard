module beard.contains;

public import std.typetuple : staticIndexOf;

/// Test if T... contains N.
template contains(N, T...) {
    enum contains = staticIndexOf!(N, T) != -1;
}

/// Test if C!T is defined for any T in T...
template containsMatch(alias C, T...) {
    static if (! T.length)
        enum containsMatch = false;
    else static if (C!(T[0]))
        enum containsMatch = true;
    else
        enum containsMatch = containsMatch!(C, T[1..$]);
}
// vim:ts=4 sw=4
