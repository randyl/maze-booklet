use Grid;

class HuntAndKill {
    method on( Grid $grid ) {
        my $current = $grid.random-cell;

        while $current {
            my @unvisited-neighbors = $current.neighbors.grep: *.links.elems == 0;

            if @unvisited-neighbors {
                my $neighbor = @unvisited-neighbors.pick;
                $current.link: $neighbor;
                $current = $neighbor;
            }
            else {
                $current = Nil;

                for $grid.each-cell -> $cell {
                    my @visited-neighbors = $cell.neighbors.grep: *.links;
                    if $cell.links == 0 && @visited-neighbors {
                        $current = $cell;
                        $current.link: @visited-neighbors.pick;
                        last;
                    }
                }
            }
        }

        return $grid;
    }
}