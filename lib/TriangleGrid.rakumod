use Grid;
use SVG;
use TriangleCell;

class TriangleGrid is Grid {
    method prepare-grid {
        for self.coordinates -> ($row, $column) {
            self[ $row; $column ] = TriangleCell.new: :$row, :$column;
        }
    }

    method configure-cells {
        for self.each-cell -> TriangleCell $cell {
            my ($row, $column) = $cell.row, $cell.column;

            $cell.west = self[ $row; $column - 1] // TriangleCell;
            $cell.east = self[ $row; $column + 1] // TriangleCell;

            if $cell.upright {
                $cell.south = self[ $row + 1; $column ] // TriangleCell;
            }
            else {
                $cell.north = self[ $row - 1; $column ] // TriangleCell;
            }
        }
    }

    method to-svg( :$cell-size = 16 ) {
        my $half-width = $cell-size / 2.0;
        my $height = $cell-size * 3.sqrt / 2.0;
        my $half-height = $height / 2.0;

        my $img-width = ($cell-size * ($.columns + 1) / 2.0).Int;
        my $img-height = ($height * $.rows).Int;

        my @g; # Group of SVG elements;

        for <backgrounds walls> -> $mode {
            for self.each-cell -> TriangleCell $cell {
                my $cx = $half-width + $cell.column * $half-width;
                my $cy = $half-height + $cell.row * $height;

                my $west-x = ($cx - $half-width).Int;
                my $mid-x  = $cx.Int;
                my $east-x = ($cx + $half-width).Int;

                my ($apex-y, $base-y);
                if $cell.upright {
                    $apex-y = ($cy - $half-height).Int;
                    $base-y = ($cy + $half-height).Int;
                }
                else {
                    $apex-y = ($cy + $half-height).Int;
                    $base-y = ($cy - $half-height).Int;
                }

                my %style = :stroke<black>;

                if $mode ~~ 'backgrounds' {
                    my $color = self.background-color-for( $cell );
                    if $color {
                        my @points = "$west-x,$base-y", "$mid-x,$apex-y", "$east-x,$base-y";
                        @g.push(
                            :polygon[ :points( @points.join(' ') ), :fill($color), :stroke($color) ]
                        );
                    }
                }
                else {
                    if !$cell.west {
                        @g.push( (:line[:x1($west-x), :y1($base-y), :x2($mid-x), :y2($apex-y), |%style]) );
                    }

                    if !$cell.linked($cell.east) {
                        @g.push( (:line[:x1($east-x), :y1($base-y), :x2($mid-x), :y2($apex-y), |%style]) );
                    }

                    my $no-south = $cell.upright && !$cell.south.defined;
                    my $not-linked = !$cell.upright && !$cell.linked($cell.north);

                    if $no-south || $not-linked {
                        @g.push( (:line[:x1($east-x), :y1($base-y), :x2($west-x), :y2($base-y), |%style]) );
                    }

                    if $cell.contents {
                        my $x = $cx;
                        my $y = $cy;
                        $y += ($cell-size * 0.1).Int if $cell.upright;
                        @g.push( (:text[
                            :$x, :$y,
                            :text-anchor<middle>, :dominant-baseline<middle>,
                            $cell.contents
                        ]) );
                    }
                }
            }
        }

        return SVG.serialize( svg => [:width($img-width + 1), :height($img-height + 1), :@g] );
    }
}