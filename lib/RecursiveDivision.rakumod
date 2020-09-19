use Cell;
use Grid;

class RecursiveDivision {
    my Grid $.grid;

    method on( Grid :$grid ) {
        $.grid = $grid;
        for $.grid.each-cell -> Cell $cell {
            $cell.link: $_, False for $cell.neighbors;
        }

        self.divide( 0, 0, $.grid.rows, $.grid.columns );
    }

    method divide( $row, $column, $height, $width ) {
        return if $height <= 1 || $width <= 1 ||
            ($height < 5 && $width < 5 && Bool.roll(4).pick);

        if $height > $width {
            self.divide-horizontally( $row, $column, $height, $width );
        }
        else {
            self.divide-vertically( $row, $column, $height, $width );
        }
    }

    method divide-horizontally( $row, $column, $height, $width ) {
        my $divide-south-of = ($height-1).rand.Int;
        my $passage-at = $width.rand.Int;

        for ^$width -> $x {
            next if $passage-at == $x;

            my $cell = $.grid[ $row + $divide-south-of; $column + $x ];
            $cell.unlink: $cell.south;
        }

        self.divide($row, $column, $divide-south-of + 1, $width );
        self.divide($row + $divide-south-of + 1, $column, $height - $divide-south-of - 1, $width );
    }

    method divide-vertically( $row, $column, $height, $width ) {
        my $divide-east-of = ($width - 1).rand.Int;
        my $passage-at = $height.rand.Int;

        for ^$height -> $y {
            next if $passage-at == $y;

            my $cell = $.grid[ $row + $y; $column + $divide-east-of ];
            $cell.unlink: $cell.east;
        }

        self.divide($row, $column, $height, $divide-east-of + 1);
        self.divide($row, $column + $divide-east-of + 1, $height, $width - $divide-east-of - 1);
    }
}