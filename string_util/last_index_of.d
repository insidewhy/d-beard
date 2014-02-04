module beard.string_util.last_index_of;

ptrdiff_t lastIndexOf(H, N)(H h, N n) {
    for (auto i = h.length; true; --i) {
        if (h[i - 1] == n) return i - 1;
        else if (! i) return -1;
    }
}
// vim:ts=4 sw=4
