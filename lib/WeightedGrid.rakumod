use Grid;
use WeightedCell;
use Distances;

class WeightedGrid is Grid {
    has $.distances is rw;
    has $!maximum;

    method prepare-grid {
        for self.coordinates -> ($row, $column) {
            self[ $row; $column ] = WeightedCell.new: :$row, :$column;
        }
    }

    method background-color-for( WeightedCell $cell --> Str ) {
        if not defined $!maximum {
            $!maximum = $!distances.max.value;
        }
        if $cell.weight > 1 {
            return "rgb(255,0,0)";
        }
        elsif $!distances {
            my $distance = $!distances{$cell} // return Nil;
            my $intensity = 64 + 191 * ($!maximum - $distance) / $!maximum;
            return "rgb($intensity, $intensity, 0)";
        }
    }
}