module beard.meta.contains;

public import std.typetuple : staticIndexOf;

// Test if T... contains N.
template contains(N, T...) {
    enum contains = staticIndexOf!(N, T) != -1;
}
