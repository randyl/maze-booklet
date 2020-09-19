use Cell;
use Grid;

class SimplifiedPrims {
    method on( Grid $grid, $start-at = $grid.random-cell ) {
        my @active = $start-at;

        while @active.elems {
            my Cell $cell = @active.pick;
            my @available-neighbors = $cell.neighbors.grep: *.links == 0;

            if @available-neighbors.elems {
                my $neighbor = @available-neighbors.pick;
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

class TruePrims {
    method on( Grid $grid, $start-at = $grid.random-cell --> Grid ) {
        my @active = $start-at;

        my %costs{Cell};
        %costs{$_} = 100.rand.Int for $grid.each-cell;

        while @active.elems {
            my Cell $cell = @active.min: { %costs{$_} };
            my @available-neighbors = $cell.neighbors.grep: *.links == 0;

            if @available-neighbors.elems {
                my $neighbor = @available-neighbors.min: { %costs{$_} };
                $cell.link: $neighbor;
                @active.push: $neighbor;
            }
            else {
                # Remove $cell from the active list.
                @active = grep { $_ !=== $cell }, @active;
            }
        }

        return $grid;
    }
}