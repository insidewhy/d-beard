module beard.vector;

template Vector(T) {
    alias T[] Vector;
}

auto ref pushBack(T, U)(ref T[] t, U u) {
    ++t.length;
    t[t.length - 1] = u;
    return t;
}

auto ref pushFront(T, U)(ref T[] t, U u) {
    T[] cpy = u ~ t;
    t = cpy;
    return t;
}
