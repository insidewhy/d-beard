module beard.inverse;

/// Modifies a boolean returning meta-function C to return the inverse.
template inverse(alias C) {
    template Inverter(T) { enum Inverter = ! C!T; }
    alias Inverter inverse;
}
// vim:ts=4 sw=4
