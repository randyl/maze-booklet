use Cell;

class TriangleCell is Cell {
    method upright( --> Bool ) {
        ($.row + $.column) %% 2;
    }

    method neighbors {
        return (
            $.west,
            $.east,
            (!$.upright ?? $.north !! Nil),
            ( $.upright ?? $.south !! Nil)
        ).grep: *.defined;
    }
}