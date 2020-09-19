use Cell;
use Grid;

class Wilsons {
    method on( Grid $grid ) {
        my %unvisited{Cell} = $grid.each-cell.antipairs.grep: *.key.defined;

        # Sort cells before picking a random one, so tests
        # can reproduce the same maze by setting srand.
        # This is needed since the order of .keys is different
        # for every program invocation, according to the Raku docs.

        my Cell $first = %unvisited.keys.sort(*.Str).pick;
        %unvisited{$first}:delete;

        while %unvisited.elems {
            my Cell $cell = %unvisited.keys.sort(*.Str).pick;
            my Cell @path = $cell;
            while %unvisited{$cell}:exists {
                $cell = $cell.neighbors.pick;
                my $position = @path.first: * === $cell, :k;
                if $position {
                    @path = @path[ 0 .. $position ];
                }
                else {
                    @path.push: $cell;
                }
            }

            for 0 .. (@path.elems - 2) -> $index {
                @path[$index].link( @path[$index + 1]);
                %unvisited{ @path[$index] }:delete;
            }
        }

        return $grid;
    }
}