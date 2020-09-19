use Cell;

class PolarCell is Cell {
    has $.cw is rw;
    has $.ccw is rw;
    has $.inward is rw;
    has @.outward;

    method neighbors {
        return ( $.cw, $.ccw, $.inward, |@.outward ).grep: *.defined;
    }
}