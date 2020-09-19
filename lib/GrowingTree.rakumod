use Cell;
use Grid;

class GrowingTree {
    method on( Grid :$grid, :$start-at = $grid.random-cell, :&next-cell = { @^list.pick } --> Grid ) {
        my @active = $start-at;

        while @active.elems {
            my Cell $cell = &next-cell( @active );
            my @available-neighbors = $cell.neighbors.grep: *.links == 0;

            if @available-neighbors.elems {
                my Cell $neighbor = @available-neighbors.pick;
                $cell.link: $neighbor;
                @active.push: $neighbor;
            }
            else {
                # Remove $cell from the active list.
                @active = @active.grep: * !=== $cell;
            }
        }

        return $grid;
    }
}