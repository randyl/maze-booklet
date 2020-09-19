use Grid;

class BinaryTree {
    method on( Grid $grid --> Grid ) {
        for $grid.each-cell -> $cell {
            my @neighbors;
            @neighbors.push: $cell.north if $cell.north;
            @neighbors.push: $cell.east  if $cell.east;

            my $neighbor = @neighbors.pick;
            $cell.link( $neighbor ) if $neighbor;
        }
        return $grid;
    }
}