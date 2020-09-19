use Cell;
use Grid;

class MaskedGrid is Grid {
    has $.mask is required;

    method new( :$mask ) {
        self.bless: :$mask, :rows($mask.rows), :columns($mask.columns);
    }

    method prepare-grid( :$mask, *% ) {
        # This object hasn't been built yet, so can't use $!mask.
        # Instead, Grid's TWEAK passes its arguments to this method.
        for self.coordinates -> ($row, $column) {
            my $value =
                $mask[$row; $column]
                ?? Cell.new: :$row, :$column
                !! Cell
            ;
            self[$row; $column] = $value;
        }
    }

    method random-cell {
        my ($row, $column) = $!mask.random-location;
        self[$row; $column];
    }

    method size {
        $!mask.count;
    }
}