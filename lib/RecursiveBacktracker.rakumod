use Cell;
use Grid;

class RecursiveBacktracker {
    method on( Grid $grid, Cell :$start-at = $grid.random-cell --> Grid ) {
        my @stack = $start-at;

        while @stack {
            my Cell $current = @stack.tail;
            my @neighbors = $current.neighbors.grep: *.links == 0;

            if @neighbors == 0 {
                @stack.pop;
            }
            else {
                my $neighbor = @neighbors.pick;
                $current.link: $neighbor;
                @stack.push: $neighbor;
            }
        }

        return $grid;
    }
}