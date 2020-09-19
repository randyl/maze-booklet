use GD::Raw;

class Mask {
    has $.rows is required;
    has $.columns is required;
    has @.bits;

    submethod TWEAK {
        for self.coordinates -> ($x, $y) {
            @!bits[ $x; $y ] = True;
        }
    }

    method coordinates {
        return ^$!rows X ^$!columns;
    }

    #| The number of enabled cells.
    method count {
        my $count = 0;
        for self.coordinates -> ($x,$y) {
            ++$count if @!bits[$x; $y];
        }
        return $count;
    }

    method random-location {
        loop {
            my $row = $!rows.rand;
            my $col = $!columns.rand;
            return ($row, $col) if @!bits[$row; $col];
        }
    }

    #| The total number of cells.
    multi method elems(::?CLASS:D:) {
        return $!rows * $!columns;
    }

    multi method AT-POS(::?CLASS:D: $row, $column) {
        return False unless 0 <= $row <= ($!rows - 1);
        return False unless 0 <= $column <= ($!columns - 1);
        return @!bits[$row; $column];
    }

    multi method EXISTS-POS(::?CLASS:D: $row, $column) {
        return 0 <= $row <= ($!rows - 1);
        return 0 <= $column <= ($!columns - 1);
    }

    multi method ASSIGN-POS (::?CLASS:D: $row, $column, $is-on) {
        @!bits[$row; $column] = $is-on;
    }

    method from-txt( Str $file where *.IO.r --> Mask ) {
        my @lines = $file.IO.lines;
        @lines.pop while @lines.tail.chars == 0;

        my $rows = @lines.elems;
        my $columns = @lines.first.chars;
        my $mask = Mask.new: :$rows, :$columns;

        for (^$mask.rows X ^$mask.columns) -> ($row, $column) {
            $mask[$row; $column] = @lines[$row].comb.[$column] ~~ '.';
        }

        return $mask;
    }

    method from-png( Str $file where *.IO.r --> Mask ) {
        my $fh = fopen( $file, 'rb' ); # Imported from GD::Raw
        my $image = gdImageCreateFromPng($fh);
        my ($columns, $rows) = gdImageSX($image), gdImageSY($image);
        my $mask = Mask.new: :$rows, :$columns;

        for (^$rows X ^$columns) -> ( $row, $column ) {
            my $pixel = gdImageGetPixel($image, $column, $row);
            my ($r,$g,$b) =
                gdImageRed($image,$pixel),
                gdImageGreen($image,$pixel),
                gdImageBlue($image,$pixel)
            ;
            $mask[$row; $column] = self!rgb_is_light($r, $g, $b);
        }

        fclose( $fh ); # Imported from GD::Raw

        return $mask;
    }

    #| Stolen from Perl's Color::RGB::Utils::rgb_is_light()
    method !rgb_is_light( *@rgb where 0 <= *.all <= 255 --> Bool ) {
        my @black = 0 xx 3;
        my @white = 255 xx 3;
        return self!rgb_distance( @rgb, @black ) > self!rgb_distance( @rgb, @white );
    }

    #| Stolen from Perl's Color::RGB::Utils::rgb_distance()
    method !rgb_distance(
        (Int $r1, Int $g1, Int $b1),
        (Int $r2, Int $g2, Int $b2)
    ) {
        ( ($r1-$r2) ** 2 + ($g1-$g2) ** 2 + ($b1-$b2) ** 2 ) ** 0.5;
    }
}