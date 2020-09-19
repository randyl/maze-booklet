use Kruskals;
use WeaveGrid;
use WeaveCells;

class SimpleOverCell is OverCell {
    method neighbors {
        ($.north, $.south, $.east, $.west).grep: *.defined;
    }
}

class PreconfiguredGrid is WeaveGrid {
    method prepare-grid {
        for self.coordinates -> ($row, $column) {
            self[ $row; $column ] = SimpleOverCell.new: :$row, :$column, :grid(self);
        }
    }
}