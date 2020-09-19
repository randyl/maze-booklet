use Cell;
use Grid;
use SVG;

class CubeCell is Cell {
    has $.face is required;

    method Str {
        self.gist;
    }

    method gist {
        "{self.^name}:{self.face},{self.row},{self.column}";
    }
}

class CubeGrid is Grid {
    multi method new( :$rows ) {
        self.bless: :$rows, :columns($rows);
    }

    method dim {
        $.rows;
    }

    method coordinates {
        return ^6 X ^self.dim X ^self.dim;
    }

    method prepare-grid {
        for self.coordinates -> ($face, $row, $column) {
            self[ $face; $row; $column ] = CubeCell.new: :$face, :$row, :$column;
        }
    }

    method configure-cells {
        for self.each-cell -> CubeCell $cell {
            my ($face, $row, $column) = $cell.face, $cell.row, $cell.column;

            $cell.west  = self[ $face; $row; $column - 1 ];
            $cell.east  = self[ $face; $row; $column + 1 ];
            $cell.north = self[ $face; $row - 1; $column ];
            $cell.south = self[ $face; $row + 1; $column ];
        }
    }

    method each-face {
        return gather take self[$_] for ^6;
    }

    method each-row {
        return gather {
            for self.each-face -> $face {
                .take for @$face;
            }
        }
    }

    method each-cell {
        return gather {
            for self.each-row -> $row {
                .take for @$row;
            }
        }
    }

    method random-cell {
        my $coord = self.coordinates.pick;
        self[ $coord[0]; $coord[1]; $coord[2] ];
    }

    method size {
        6 * self.dim * self.dim;
    }

    multi method AT-POS(::?CLASS:D: $face is copy, $row is copy, $column is copy) is rw {
        return Nil unless 0 <= $face <= 6;
        ($face, $row, $column) = self.wrap( $face, $row, $column);
        self[ $face ][ $row ][ $column ]; # Invokes AT-POS of parent class.
    }

    method wrap( $face, $row, $column ) {
        my $n = self.dim - 1;

        if $row < 0 {
            return [4, $column, 0]       if $face == 0;
            return [4, $n, $column]      if $face == 1;
            return [4, $n - $column, $n] if $face == 2;
            return [4, 0, $n - $column]  if $face == 3;
            return [3, 0, $n - $column]  if $face == 4;
            return [1, $n, $column]      if $face == 5;
        }
        elsif $row >= self.dim {
            return [5, $n - $column, 0]  if $face == 0;
            return [5, 0, $column]       if $face == 1;
            return [5, $column, $n]      if $face == 2;
            return [5, $n, $n - $column] if $face == 3;
            return [1, 0, $column]       if $face == 4;
            return [3, $n, $n - $column] if $face == 5;
        }
        elsif $column < 0 {
            return [3, $row, $n]         if $face == 0;
            return [0, $row, $n]         if $face == 1;
            return [1, $row, $n]         if $face == 2;
            return [2, $row, $n]         if $face == 3;
            return [0, 0, $row]          if $face == 4;
            return [0, $n, $n - $row]    if $face == 5;
        }
        elsif $column >= self.dim {
            return [1, $row, 0]          if $face == 0;
            return [2, $row, 0]          if $face == 1;
            return [3, $row, 0]          if $face == 2;
            return [0, $row, 0]          if $face == 3;
            return [2, 0, $n - $row]     if $face == 4;
            return [2, $n, $row]         if $face == 5;
        }

        return [$face, $row, $column];
    }

    method to-svg( :$cell-size = 10, :$inset is copy = 0, :$text-offset = 5 ) {
        $inset = ($cell-size * $inset).Int;

        my $face-width = $cell-size * self.dim;
        my $face-height = $cell-size * self.dim;

        my $img-width = 4 * $face-width;
        my $img-height = 3 * $face-height;

        my @offsets = [0,1], [1,1], [2,1], [3,1], [1,0], [1,2];

        my %style = stroke => 'black';
        my %outline = stroke => 'lightgray';
        my @g; # Group of SVG elements

        self.draw-outlines: @g, $face-width, $face-height, %outline;

        for <backgrounds walls> -> $mode {
            for self.each-cell -> CubeCell $cell {
                my $x = @offsets[$cell.face][0] * $face-width + $cell.column * $cell-size;
                my $y = @offsets[$cell.face][1] * $face-height + $cell.row * $cell-size;

                if $inset > 0 {
                    self.to-svg-with-inset(@g, $cell, $mode, $cell-size, %style, $x, $y, $inset, $text-offset);
                }
                else {
                    self.to-svg-without-inset(@g, $cell, $mode, $cell-size, %style, $x, $y, $text-offset);
                }
            }
        }

        @g.push(
            (:text[
                :x(500), :y(100), :font-size<15px>,
                "Cut out, fold, and tape to make a CUBE MAZE!!!"
            ])
        );

        return SVG.serialize( svg => [ :width($img-width+1), :height($img-height+1), :@g ] );
    }

    method draw-outlines( @g, $height, $width, %outline ) {
        # face 0
        @g.push((:rect[
            :x(0), :y($height),
            :$width, :$height,
            :fill-opacity(0),
            |%outline
        ]));

        # faces 2 & 3
        @g.push((:rect[
            :x($width*2), :y($height),
            :width($width*2), :$height,
            :fill-opacity(0),
            |%outline
        ]));
        # line between faces 2 & 3
        @g.push((:line[:x1($width*3), :y1($height), :x2($width*3), :y2($height*2), |%outline]));

        # face 4
        @g.push((:rect[
            :x($width), :y(0),
            :$width, :$height,
            :fill-opacity(0),
            |%outline
        ]));

        # face 5
        @g.push((:rect[
            :x($width), :y($height*2),
            :$width, :$height,
            :fill-opacity(0),
            |%outline
        ]));
    }

    method to-svg-without-inset(@g, $cell, $mode, $cell-size, %style, $x, $y, $text-offset) {
        my ($x1, $y1) = $x, $y;
        my $x2 = $x1 + $cell-size;
        my $y2 = $y1 + $cell-size;

        if $mode ~~ 'backgrounds' {
            my $color = self.background-color-for: $cell;
            if $color {
                @g.push((:rect[
                    :$x, :$y,
                    :width($x2), :height($x2),
                    :fill($color)
                ]));
            }
        }
        else {
            if $cell.north.face != $cell.face && !$cell.linked: $cell.north {
                @g.push((:line[:$x1, :$y1, :$x2, :y2($y1), |%style]));
            }

            if $cell.west.face != $cell.face && !$cell.linked: $cell.west {
                @g.push((:line[:$x1, :$y1, :x2($x1), :$y2, |%style]));
            }

            @g.push((:line[:x1($x2), :$y1, :$x2, :$y2, |%style])) unless $cell.linked: $cell.east;
            @g.push((:line[:$x1, :y1($y2), :$x2, :$y2, |%style])) unless $cell.linked: $cell.south;

            if $cell.contents {
                my $x = $x1 + $cell-size / 2;
                my $y = $y1 + $cell-size / 2;
                @g.push( (:text[
                    :$x, :$y,
                    :text-anchor<middle>, :dominant-baseline<middle>,
                    $cell.contents
                ]) );
            }
        }
    }
}