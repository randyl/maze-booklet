use Grid;
use WeaveCells;

class WeaveGrid is Grid {
    has @!under-cells;

    method prepare-grid {
        for self.coordinates -> ($row, $column) {
            self[ $row; $column ] = OverCell.new: :$row, :$column, :grid(self);
        }
    }

    method tunnel-under( OverCell $over-cell ) {
        @!under-cells.push: UnderCell.new: $over-cell;
    }

    method each-cell {
        my @cells = callsame;
        @cells.push: |@!under-cells;
        return gather .take for @cells;
    }

    method to-svg( :$cell-size = 10, :$inset ) {
        callwith :$cell-size, :inset($inset // 0.2);
    }

    method to-svg-with-inset(@g, $cell, $mode, $cell-size, %style, $x, $y, $inset ) {
        if $cell.isa: OverCell {
            callsame;
        }
        else {
            my ($x1, $x2, $x3, $x4, $y1, $y2, $y3, $y4) = |self.cell-coordinates-with-inset: $x, $y, $cell-size, $inset;
            if $cell.vertical-passage {
                @g.push((:line[:x1($x2), :$y1,     :$x2,     :$y2,     |%style]));
                @g.push((:line[:x1($x3), :$y1,     :x2($x3), :$y2,     |%style]));
                @g.push((:line[:x1($x2), :y1($y3), :$x2,     :y2($y4), |%style]));
                @g.push((:line[:x1($x3), :y1($y3), :x2($x3), :y2($y4), |%style]));
            }
            else {
                @g.push((:line[:$x1,     :y1($y2), :$x2,     :$y2,     |%style]));
                @g.push((:line[:$x1,     :y1($y3), :$x2,     :y2($y3), |%style]));
                @g.push((:line[:x1($x3), :y1($y2), :x2($x4), :$y2,     |%style]));
                @g.push((:line[:x1($x3), :y1($y3), :x2($x4), :y2($y3), |%style]));
            }
        }
    }
}