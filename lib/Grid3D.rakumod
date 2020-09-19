use Cell;
use Grid;
use SVG;

class Cell3D is Cell {
    has $.level is required;
    has $.up is rw = Cell3D;
    has $.down is rw = Cell3D;

    method neighbors {
        my @neighbors = callsame;
        @neighbors.push: $!up   if $!up;
        @neighbors.push: $!down if $!down;
        return @neighbors;
    }

    method Str {
        self.gist;
    }

    method gist {
        "{self.^name}:{ self.level },{ self.row },{ self.column }";
    }
}

class Grid3D is Grid {
    has $.levels is required;

    method prepare-grid( :$levels, *% ) {
        for ^$levels X ^$.rows X ^$.columns -> ($level, $row, $column) {
            self[ $level; $row; $column ] = Cell3D.new: :$level, :$row, :$column;
        }
    }

    method configure-cells( :$levels, *% ) {
        for ^$levels X ^$.rows X ^$.columns -> ($level, $row, $column) {
            my Cell3D $cell = self[ $level; $row; $column ];

            $cell.north = self[ $level; $row - 1; $column ] // Cell3D;
            $cell.south = self[ $level; $row + 1; $column ] // Cell3D;
            $cell.west  = self[ $level; $row; $column - 1 ] // Cell3D;
            $cell.east  = self[ $level; $row; $column + 1 ] // Cell3D;
            $cell.down  = self[ $level - 1; $row; $column ] // Cell3D;
            $cell.up    = self[ $level + 1; $row; $column ] // Cell3D;
        }
    }

    method random-cell {
        my $coord = (^$!levels X ^$.rows X ^$.columns).pick;
        return self[ $coord[0]; $coord[1]; $coord[2] ];
    }

    method size {
        return $!levels * callsame;
    }

    method each-level {
        return gather take self[$_] for ^$!levels;
    }

    method each-row {
        return gather {
            for self.each-level -> $level {
                .take for @$level;
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

    method to-svg( :$cell-size = 10, :$inset = 0, :$margin = $cell-size / 1 ) {
        my $cell-inset = ($cell-size * $inset).Int;

        my $grid-width  = $cell-size * $.columns;
        my $grid-height = $cell-size * $.rows;

        my $img-width = $grid-width * $!levels + ($!levels - 1 ) * $margin;
        my $img-height = $grid-height;

        my %style = stroke => 'black';
        my %arrow = stroke => 'red';
        my @g; # Group of SVG elements

        for <backgrounds walls> -> $mode {
            for self.each-cell -> Cell $cell {
                my $x = $cell.level * ($grid-width + $margin) + $cell.column * $cell-size;
                my $y = $cell.row * $cell-size;

                if $inset > 0 {
                    self.to-svg-with-inset( @g, $cell, $mode, $cell-size, %style, $x, $y, $cell-inset );
                }
                else {
                    self.to-svg-without-inset( @g, $cell, $mode, $cell-size, %style, $x, $y );
                }

                if $mode ~~ 'walls' {
                    my $mid-x = $x + $cell-size / 2;
                    my $mid-y = $y + $cell-size / 2;

                    if $cell.linked: $cell.down {
                        @g.push( (:line[ :x1($mid-x - 3), :y1($mid-y), :x2($mid-x - 1), :y2($mid-y + 2), |%arrow ]));
                        @g.push( (:line[ :x1($mid-x - 3), :y1($mid-y), :x2($mid-x - 1), :y2($mid-y - 2), |%arrow ]));
                    }

                    if $cell.linked: $cell.up {
                        @g.push( (:line[ :x1($mid-x + 3), :y1($mid-y), :x2($mid-x + 1), :y2($mid-y + 2), |%arrow ]));
                        @g.push( (:line[ :x1($mid-x + 3), :y1($mid-y), :x2($mid-x + 1), :y2($mid-y - 2), |%arrow ]));
                    }
                }
            }
        }

        return SVG.serialize( svg => [ :width($img-width+1), :height($img-height+1), :@g ] );
    }
}