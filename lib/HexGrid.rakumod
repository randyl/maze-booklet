use Grid;
use HexCell;
use SVG;

class HexGrid is Grid {
    method prepare-grid {
        for self.coordinates -> ($row, $column) {
            self[ $row; $column ] = HexCell.new: :$row, :$column;
        }
    }

    method configure-cells {
        for self.each-cell -> HexCell $cell {
            my ($row, $column) = $cell.row, $cell.column;

            my ($north-diagonal, $south-diagonal);

            if ($column %% 2) {
                $north-diagonal = $row - 1;
                $south-diagonal = $row;
            }
            else {
                $north-diagonal = $row;
                $south-diagonal = $row + 1;
            }

            $cell.northwest = self[ $north-diagonal; $column - 1] // HexCell;
            $cell.north     = self[ $row - 1; $column ]           // HexCell;
            $cell.northeast = self[ $north-diagonal; $column + 1] // HexCell;
            $cell.southwest = self[ $south-diagonal; $column - 1] // HexCell;
            $cell.south     = self[ $row + 1; $column ]           // HexCell;
            $cell.southeast = self[ $south-diagonal; $column + 1] // HexCell;
        }
    }

    method to-svg( :$cell-size = 10 ) {
        my $a-size = $cell-size / 2.0;
        my $b-size = $cell-size * 3.sqrt / 2.0;
        my $width  = $cell-size * 2;
        my $height = $b-size * 2;

        my $img-width  = (3 * $a-size * $.columns + $a-size + 0.5).Int;
        my $img-height = ($height * $.rows + $b-size + 0.5).Int;

        my %style = :stroke<black>;
        my @g; # Group of SVG elements

        for <backgrounds walls> -> $mode {
            for self.each-cell -> HexCell $cell {
                my $cx = $cell-size + 3 * $cell.column * $a-size;
                my $cy = $b-size + $cell.row * $height;
                $cy += $b-size if $cell.column % 2 == 1;

                # f/n = far/near
                # n/s/e/w = north/south/east/west
                my $x-fw = ($cx - $cell-size).Int;
                my $x-nw = ($cx - $a-size).Int;
                my $x-ne = ($cx + $a-size).Int;
                my $x-fe = ($cx + $cell-size).Int;

                # m = middle
                my $y-n = ($cy - $b-size).Int;
                my $y-m = $cy.Int;
                my $y-s = ($cy + $b-size).Int;

                if $mode ~~ 'backgrounds' {
                    my $color = self.background-color-for: $cell;
                    if $color {
                        my @points =
                            "$x-fw,$y-m", "$x-nw,$y-n", "$x-ne,$y-n",
                            "$x-fe,$y-m", "$x-ne,$y-s", "$x-nw,$y-s",
                        ;
                        @g.push( :polygon[ :points( @points.join(' ') ) ], :fill($color), :stroke($color) );
                    }
                }
                else {
                    @g.push((line => [:x1($x-fw), :y1($y-m), :x2($x-nw), :y2($y-s), |%style])) unless $cell.southwest;
                    @g.push((line => [:x1($x-fw), :y1($y-m), :x2($x-nw), :y2($y-n), |%style])) unless $cell.northwest;
                    @g.push((line => [:x1($x-nw), :y1($y-n), :x2($x-ne), :y2($y-n), |%style])) unless $cell.north;
                    @g.push((line => [:x1($x-ne), :y1($y-n), :x2($x-fe), :y2($y-m), |%style])) unless $cell.linked($cell.northeast);
                    @g.push((line => [:x1($x-fe), :y1($y-m), :x2($x-ne), :y2($y-s), |%style])) unless $cell.linked($cell.southeast);
                    @g.push((line => [:x1($x-ne), :y1($y-s), :x2($x-nw), :y2($y-s), |%style])) unless $cell.linked($cell.south);

                    if $cell.contents {
                        @g.push( (:text[
                            :x($cx), :y($cy),
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