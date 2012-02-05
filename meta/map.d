module beard.meta.map;

public import beard.meta.fold_left : foldLeft;
public import beard.meta.type_list : TL;

template map(alias C, T...) {
    template fold(alias R, U) { alias R.append!(C!U) fold; }

    alias foldLeft!(fold, TL!(), T).types map;
}
