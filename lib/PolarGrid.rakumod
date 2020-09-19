use Cell;
use Grid;
use PolarCell;
use SVG;

class PolarGrid is Grid {
    constant π = π; # Makes Comma IDE stop complaining about undeclared subroutine π.

    multi method new( :$rows ) {
        self.bless: :$rows, :columns(1);
    }

    method prepare-grid {
        my $row-height = 1.0 / $.rows;
        self[0; 0] = PolarCell.new: :row(0), :column(0);

        for 1 ..^ $.rows -> $row {
            my $radius = $row / $.rows;
            my $circumference = 2 * π * $radius;

            my $previous-count = self[$row - 1; *].elems;
            my $estimated-cell-width = $circumference / $previous-count;
            my $ratio = ($estimated-cell-width / $row-height).round;

            my $cells = $previous-count * $ratio;
            for ^$cells -> $column {
                self[$row; $column] = PolarCell.new: :$row, :$column;
            }
        }
    }

    method configure-cells {
        for self.each-cell -> PolarCell $cell {
            my ($row, $col) = $cell.row, $cell.column;
            if $row > 0 {
                $cell.cw  = self[ $row; $col + 1] // PolarCell;
                $cell.ccw = self[ $row; $col - 1] // PolarCell;

                my $ratio = self[$row; *].elems / self[$row - 1; *].elems;
                my $parent = self[$row - 1; $col / $ratio ];
                $parent.outward.push: $cell;
                $cell.inward = $parent;
            }
        }
    }

    multi method AT-POS(::?CLASS:D: $row, $column) is rw {
        my $wrapped-column = $column % self[ $row; *].elems;
        self[ $row ][ $wrapped-column ]; # Invokes AT-POS of parent class.
    }

    method random-cell {
        return self[*; *].pick;
    }

    method to-svg( :$cell-size = 10, :$text-offset = 5 ) {
        my $img-size = 2 * $.rows * $cell-size;

        my %style = stroke => 'black';
        my @g;  # Group of SVG elements

        my $center = $img-size / 2;
        @g.push( (:text[
            :x($center - $text-offset),
            :y($center + $text-offset),
            self[0;0].contents
        ]) );

        for self.each-cell -> Cell $cell {
            next if $cell.row == 0;

            my $theta = (2 * π) / self[ $cell.row; * ].elems;
            my $inner-radius = $cell.row * $cell-size;
            my $outer-radius = ($cell.row + 1) * $cell-size;
            my $theta-ccw = $cell.column * $theta;
            my $theta-cw = ($cell.column + 1) * $theta;

            my $ax = $center + ($inner-radius * cos $theta-ccw);
            my $ay = $center + ($inner-radius * sin $theta-ccw);
            my $bx = $center + ($outer-radius * cos $theta-ccw);
            my $by = $center + ($outer-radius * sin $theta-ccw);
            my $cx = $center + ($inner-radius * cos $theta-cw);
            my $cy = $center + ($inner-radius * sin $theta-cw);
            my $dx = $center + ($outer-radius * cos $theta-cw);
            my $dy = $center + ($outer-radius * sin $theta-cw);

            if ($cell.contents.defined) {
                # Calculate the midpoint of the cell.
                my $theta-cw = ($cell.column + 0.5) * $theta;
                my $mid-radius = $inner-radius + ($outer-radius - $inner-radius) / 2;
                my $x = $center + ($mid-radius * cos $theta-cw) - $text-offset;
                my $y = $center + ($mid-radius * sin $theta-cw) + $text-offset;
                @g.push( (:text[:$x, :$y, $cell.contents ]) );
            }

            @g.push( (:line[:x1($ax), :y1($ay), :x2($cx), :y2($cy), |%style]) )
                unless $cell.linked($cell.inward);
            @g.push( (:line[:x1($cx), :y1($cy), :x2($dx), :y2($dy), |%style]) )
                unless $cell.linked($cell.cw);
        }

        @g.push( (:circle[
            :cx($center),
            :cy($center),
            :r( $.rows * $cell-size ),
            :fill-opacity(0),
            |%style,
        ]) );

        return SVG.serialize( svg => [:width($img-size + 1), :height($img-size + 1), :@g] );
    }
}