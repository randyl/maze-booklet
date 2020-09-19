use Grid;

class CylinderGrid is Grid {

    multi method AT-POS(::?CLASS:D: $row, $column) is rw {
        return Nil unless 0 <= $row <= $.rows - 1;
        my $wrapped-column = $column % self[ $row; *].elems;
        self[ $row ][ $wrapped-column ]; # Invokes AT-POS of parent class.
    }

}