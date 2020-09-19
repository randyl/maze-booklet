use Cell;
use Grid;

class AldousBroder {
    method on( Grid $grid ) {
        my Cell $cell = $grid.random-cell;
        my $unvisited = $grid.size - 1;

        while $unvisited > 0 {
            my Cell $neighbor = $cell.neighbors.pick;

            if $neighbor.links.elems == 0 {
                $cell.link( $neighbor );
                $unvisited -= 1;
            }

            $cell = $neighbor;
        }

        return $grid;
    }
}