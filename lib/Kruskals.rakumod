use Grid;
use Cell;

class Kruskals {

    class State {
        has Grid $!grid is required;
        has @.neighbors;
        has %!set_for_cell{Cell};
        has %!cells_in_set{Int};

        submethod BUILD( :$!grid ) {}

        submethod TWEAK {
            for $!grid.each-cell -> Cell $cell {
                next unless $cell;

                my $set = %!set_for_cell.elems;

                %!set_for_cell{$cell} = $set;
                %!cells_in_set{$set} = [ $cell ];

                @!neighbors.push: [ $cell, $cell.south ] if $cell.south;
                @!neighbors.push: [ $cell, $cell.east  ] if $cell.east;
            }
        }

        method can-merge( Cell $left, Cell $right --> Bool ) {
            return False unless $left.defined;
            return False unless $right.defined;
            return %!set_for_cell{$left} != %!set_for_cell{$right};
        }

        method merge( Cell $left, Cell $right ) {
            $left.link: $right;

            my $winner = %!set_for_cell{$left} // -1;
            my $loser  = %!set_for_cell{$right} // -1;
            my @losers = |( %!cells_in_set{$loser} // [$right] );

            for @losers -> Cell $cell {
                %!cells_in_set{$winner}.push: $cell;
                %!set_for_cell{$cell} = $winner;
            }

            %!cells_in_set{$loser}:delete;
        }

        method add-crossing( Cell $cell --> Bool ) {
            return False if
                $cell.links.elems ||
                !self.can-merge($cell.east, $cell.west) ||
                !self.can-merge($cell.north, $cell.south)
            ;

            # Remove all neighbor pairs that include the current cell.
            @!neighbors = grep { $cell !=== any |$_ }, @!neighbors;

            if Bool.pick {
                self.merge: $cell.west, $cell;
                self.merge: $cell, $cell.east;

                $!grid.tunnel-under: $cell;
                self.merge: $cell.north, $cell.north.south;
                self.merge: $cell.south, $cell.south.north;
            }
            else {
                self.merge: $cell.north, $cell;
                self.merge: $cell, $cell.south;

                $!grid.tunnel-under: $cell;
                self.merge: $cell.west, $cell.west.east;
                self.merge: $cell.east, $cell.east.west;
            }

            return True;
        }
    }

    method on( Grid $grid, $state = State.new: :$grid --> Grid ) {
        my @neighbors = $state.neighbors.pick: *;

        while @neighbors.elems {
            my ($left, $right) = |@neighbors.pop;
            $state.merge: $left, $right if $state.can-merge: $left, $right;
        }

        return $grid;
    }
}