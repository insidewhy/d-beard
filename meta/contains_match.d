module beard.meta.contains_match;

// Test if C!T is defined for any T in T...
template containsMatch(alias C, T...) {
    static if (! T.length)
        enum containsMatch = false;
    else static if (C!(T[0]))
        enum containsMatch = true;
    else
        enum containsMatch = containsMatch!(C, T[1..$]);
}
