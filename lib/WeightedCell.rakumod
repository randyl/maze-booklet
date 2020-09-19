use Cell;
use Distances;

class WeightedCell is Cell {
    has $.weight is rw = 1;

    method distances( --> Distances ) {
        my $weights = Distances.new: :root(self);
        my @pending = self;

        while @pending.elems {
            my ($index, $cell) = @pending.sort( { $weights{$_} } ).first: :kv;
            @pending.splice: $index, 1;

            for $cell.links -> Cell $neighbor {
                my $total-weight = $weights{$cell} + $neighbor.weight;

                if !$weights{$neighbor}.defined || $total-weight < $weights{$neighbor} {
                    @pending.push: $neighbor;
                    $weights{$neighbor} = $total-weight;
                }
            }
        }

        return $weights;
    }
}