use Cell;
use CylinderGrid;
use SVG;

class MoebiusGrid is CylinderGrid {
    multi method new( :$rows, :$columns ) {
        self.bless: :$rows, :columns($columns * 2);
    }

    method to-svg( :$cell-size = 10, :$inset = 0 ) {
        my $grid-height = $cell-size * $.rows;
        my $mid-point = $.columns / 2;

        my $img-width = $cell-size * $mid-point;
        my $img-height = $grid-height * 2;

        my $cell-inset = ($cell-size * $inset).Int;

        my %style = stroke => 'black';
        my @g;  # Group of SVG elements

        for <backgrounds walls> -> $mode {
            for self.each-cell -> Cell $cell {
                my $x = ($cell.column % $mid-point) * $cell-size;
                my $y = $cell.row * $cell-size;

                $y += $grid-height if $cell.column >= $mid-point;

                if $cell-inset > 0 {
                    self.to-svg-with-inset(@g, $cell, $mode, $cell-size, %style, $x, $y, $cell-inset);
                }
                else {
                    self.to-svg-without-inset(@g, $cell, $mode, $cell-size, %style, $x, $y);
                }
            }
        }

        return SVG.serialize( svg => [:width($img-width+1), :height($img-height+1), :@g] );
    }
}