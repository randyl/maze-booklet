use Grid;

class Sidewinder {

    method on( Grid $grid --> Grid ) {
        for $grid.each-row -> @row {
            my @run;
            for @row -> $cell {
                @run.push: $cell;
                my $at-eastern-boundary = !$cell.east.defined;
                my $at-northern-boundary = !$cell.north.defined;

                my $should-close-out = $at-eastern-boundary || (!$at-northern-boundary && Bool.pick);

                if $should-close-out {
                    my $member = @run.pick;
                    $member.link( $member.north ) if $member.north;
                    @run = ();
                }
                else {
                    $cell.link( $cell.east );
                }
            }
        }

        return $grid;
    }
}