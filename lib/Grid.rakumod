use Cell;
use SVG;

class Grid {
    has $.rows is required;
    has $.columns is required;
    has @!grid;

    submethod TWEAK( |c ) {
        self.prepare-grid( |c );
        self.configure-cells( |c );
    }

    method coordinates {
        return ^$!rows X ^$!columns;
    }

    method prepare-grid {
        for self.coordinates -> ($row, $column) {
            self[ $row; $column ] = Cell.new( :$row, :$column );
        }
    }

    method configure-cells {
        for self.each-cell -> Cell $cell {
            next unless $cell;
            my ($row, $column) = $cell.row, $cell.column;
            $cell.north = self[ $row - 1; $column ] // Cell;
            $cell.south = self[ $row + 1; $column ] // Cell;
            $cell.west  = self[ $row; $column - 1 ] // Cell;
            $cell.east  = self[ $row; $column + 1 ] // Cell;
        }
    }

    method each-cell {
        return gather {
            for self.each-row -> $row {
                .take for @$row;
            }
        }
    }

    method each-row {
        return gather {
            take @!grid[ $_ ] for ^$!rows;
        }
    }

    method random-cell {
        my $coord = self.coordinates.pick;
        self[ $coord[0]; $coord[1] ];
    }

    method size {
        return self.elems;
    }

    method deadends {
        return self.each-cell.grep: *.links.elems == 1;
    }

    method braid( $p = 1.0 ) {
        for self.deadends.pick: * -> Cell $cell {
            next if $cell.links.elems != 1 || rand > $p;

            my @neighbors = $cell.neighbors.grep: !*.linked($cell);
            my @best = @neighbors.grep: *.links.elems == 1;
            @best = @neighbors if !@best.elems;

            $cell.link: @best.pick;
        }
    }

    method Str {
        my $output = '+' ~ ('---+' x $!columns) ~ "\n";
        for self.each-row -> $row {
            my $top = '|';
            my $bottom = '+';

            for @$row -> Cell $row-cell {
                my Cell $cell = $row-cell // Cell.new: :row(-1), :column(-1);

                my $body = " $.contents-of($cell) ";
                my $east_boundary = $cell.linked( $cell.east ) ?? ' ' !! '|';
                $top ~= $body ~ $east_boundary;

                my $south_boundary = $cell.linked( $cell.south ) ?? (' ' x 3) !! '---';
                my $corner = '+';
                $bottom ~= $south_boundary ~ $corner;
            }

            $output ~= $top ~ "\n";
            $output ~= $bottom ~ "\n";
        }

        return $output;
    }

    method gist {
        return self.Str;
    }

    multi method elems(::?CLASS:D:) {
        $!rows * $!columns;
    }

    multi method AT-POS(::?CLASS:D: $index) is rw {
        @!grid[ $index ];
    }

    multi method ASSIGN-POS (::?CLASS:D: $index, $new) {
        @!grid[ $index ] = $new;
    }

    multi method EXISTS-POS(::?CLASS:D: $index) {
        @!grid[ $index ]:exists;
    }

    method to-svg( :$cell-size = 10, :$inset = 0 ) {
        my $width = $cell-size * $!columns;
        my $height = $cell-size * $!rows;
        my $cell-inset = ($cell-size * $inset).Int;

        my %style = stroke => 'black';
        my @g; # Group of SVG elements

        for <backgrounds walls> -> $mode {
            for self.each-cell -> Cell $cell {
                next unless $cell;
                my $x = $cell.column * $cell-size;
                my $y = $cell.row * $cell-size;

                if $inset > 0 {
                    self.to-svg-with-inset( @g, $cell, $mode, $cell-size, %style, $x, $y, $cell-inset );
                }
                else {
                    self.to-svg-without-inset( @g, $cell, $mode, $cell-size, %style, $x, $y );
                }
            }
        }

        return SVG.serialize( svg => [ :$width, :$height, :@g ] );
    }

    method to-svg-without-inset(@g, $cell, $mode, $cell-size, %style, $x, $y ) {
        my ($x1, $y1) = $x, $y;
        my $x2 = $x1 + $cell-size;
        my $y2 = $y1 + $cell-size;

        if $mode ~~ 'backgrounds' {
            my $color = self.background-color-for( $cell );
            if $color {
                @g.push(
                    (:rect[
                        :x($x1), :y($y1),
                        :width($cell-size), :height($cell-size),
                        :fill($color)
                    ])
                );
            }
        }
        else {
            @g.push((:line[:$x1, :$y1, :$x2, :y2($y1), |%style])) unless $cell.north;
            @g.push((:line[:$x1, :$y1, :x2($x1), :$y2, |%style])) unless $cell.west;

            @g.push((:line[:x1($x2), :$y1, :$x2, :$y2, |%style])) unless $cell.linked($cell.east);
            @g.push((:line[:$x1, :y1($y2), :$x2, :$y2, |%style])) unless $cell.linked($cell.south);

            if $cell.contents {
                my $x = $x1 + $cell-size / 2;
                my $y = $y1 + $cell-size / 2;
                @g.push( (:text[
                    :$x, :$y,
                    :text-anchor<middle>, :dominant-baseline<middle>,
                    $cell.contents
                ]) );
            }
        }
    }

    method to-svg-with-inset(@g, $cell, $mode, $cell-size, %style, $x, $y, $inset ) {
        my ($x1, $x2, $x3, $x4, $y1, $y2, $y3, $y4) = |self.cell-coordinates-with-inset($x, $y, $cell-size, $inset);

        if $mode ~~ 'backgrounds' {
            # TODO: Not implemented in book
        }
        else {
            if $cell.linked: $cell.north {
                @g.push((:line[:x1($x2), :$y1, :$x2,     :$y2, |%style]));
                @g.push((:line[:x1($x3), :$y1, :x2($x3), :$y2, |%style]));
            }
            else {
                @g.push((:line[:x1($x2), :y1($y2), :x2($x3), :$y2, |%style]));
            }

            if $cell.linked: $cell.south {
                @g.push((:line[:x1($x2), :y1($y3), :$x2,     :y2($y4), |%style]));
                @g.push((:line[:x1($x3), :y1($y3), :x2($x3), :y2($y4), |%style]));
            }
            else {
                @g.push((:line[:x1($x2), :y1($y3), :x2($x3), :y2($y3), |%style]));
            }

            if $cell.linked: $cell.west {
                @g.push((:line[:$x1, :y1($y2), :$x2, :$y2,     |%style]));
                @g.push((:line[:$x1, :y1($y3), :$x2, :y2($y3), |%style]));
            }
            else {
                @g.push((:line[:x1($x2), :y1($y2), :$x2, :y2($y3), |%style]));
            }

            if $cell.linked: $cell.east {
                @g.push((:line[:x1($x3), :y1($y2), :x2($x4), :$y2,     |%style]));
                @g.push((:line[:x1($x3), :y1($y3), :x2($x4), :y2($y3), |%style]));
            }
            else {
                @g.push((:line[:x1($x3), :y1($y2), :x2($x3), :y2($y3), |%style]));
            }

            if $cell.contents {
                my $x = $x1 + $cell-size / 2;
                my $y = $y1 + $cell-size / 2;
                @g.push( (:text[
                    :$x, :$y,
                    :text-anchor<middle>, :dominant-baseline<middle>,
                    $cell.contents
                ]) );
            }
        }
    }

    method cell-coordinates-with-inset( $x, $y, $cell-size, $inset ) {
        my ($x1, $x4) = $x, $x + $cell-size;
        my $x2 = $x1 + $inset;
        my $x3 = $x4 - $inset;

        my ($y1, $y4) = $y, $y + $cell-size;
        my $y2 = $y1 + $inset;
        my $y3 = $y4 - $inset;

        return (
            $x1, $x2, $x3, $x4,
            $y1, $y2, $y3, $y4
        );
    }

    method contents-of( Cell $cell ) {
        return $cell.contents // ' ';
    }

    method background-color-for( Cell $cell ) {
        return Nil;
    }

    method middle-cell( --> Cell ) {
        return self[ self.rows / 2; self.columns / 2 ];
    }
}