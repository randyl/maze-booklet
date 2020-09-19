use Cell;

class HexCell is Cell {
    has $.northeast is rw = HexCell;
    has $.northwest is rw = HexCell;
    has $.southeast is rw = HexCell;
    has $.southwest is rw = HexCell;

    method neighbors {
        return ($.northwest, $.north, $.northeast, $.southwest, $.south, $.southeast).grep: *.defined;
    }
}