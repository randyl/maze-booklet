use Cell;
use Grid;

class Ellers {

    class RowState {
        has %!cells-in-set{Int};
        has %!set-for-cell{Int};
        has Int $!next-set;

        submethod BUILD( Int :$starting-set = 0 ) {
            $!next-set = $starting-set;
        }

        method record( Int $set, Cell $cell ) {
            %!set-for-cell{$cell.column} = $set;

            %!cells-in-set{$set} = [] if !%!cells-in-set{$set};
            %!cells-in-set{$set}.push: $cell;
        }

        method set-for( Cell $cell ) {
            if !%!set-for-cell{$cell.column} {
                self.record( $!next-set, $cell );
                $!next-set++;
            }

            return %!set-for-cell{$cell.column};
        }

        method merge( Int $winner, Int $loser ) {
            for %!cells-in-set{$loser}.flat -> Cell $cell {
                %!set-for-cell{$cell.column} = $winner;
                %!cells-in-set{$winner}.push: $cell;
            }

            return %!cells-in-set{$loser}:delete;
        }

        method next( --> RowState ) {
            RowState.new: :starting-set($!next-set);
        }

        method each-set {
            return gather take(.key, .value) for %!cells-in-set.sort;
        }
    }

    method on( Grid :$grid ) {
        my $row-state = RowState.new;
        for $grid.each-row -> @row {
            for @row -> Cell $cell {
                next unless $cell.west;

                my $set = $row-state.set-for: $cell;
                my $prior-set = $row-state.set-for: $cell.west;
                my $should-link = $set != $prior-set && (!$cell.south.defined || Bool.pick);
                if $should-link {
                    $cell.link: $cell.west;
                    $row-state.merge: $prior-set, $set;
                }
            }

            if @row[0].south {
                my RowState $next-row = $row-state.next;

                for $row-state.each-set -> ($set, @cells) {
                    for @cells.pick(*).kv -> $index, Cell $cell {
                        if $index == 0 || (^3).pick == 0 {
                            $cell.link: $cell.south;
                            $next-row.record: $row-state.set-for($cell), $cell.south;
                        }
                    }
                }

                $row-state = $next-row;
            }
        }
    }
}