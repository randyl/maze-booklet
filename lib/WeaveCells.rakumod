use Cell;

class OverCell is Cell {
    has $!grid is required;

    submethod BUILD( :$!grid ) {}

    method neighbors {
        my @neighbors = callsame;
        @neighbors.push: $.north.north if self.can-tunnel-north;
        @neighbors.push: $.south.south if self.can-tunnel-south;
        @neighbors.push: $.east.east   if self.can-tunnel-east;
        @neighbors.push: $.west.west   if self.can-tunnel-west;

        return @neighbors;
    }

    method can-tunnel-north( --> Bool ) {
        ?($.north && $.north.north && $.north.horizontal-passage);
    }

    method can-tunnel-south( --> Bool ) {
        ?($.south && $.south.south && $.south.horizontal-passage);
    }

    method can-tunnel-east( --> Bool ) {
        ?($.east && $.east.east && $.east.vertical-passage);
    }

    method can-tunnel-west( --> Bool ) {
        ?($.west && $.west.west && $.west.vertical-passage);
    }

    method horizontal-passage( --> Bool ) {
        ?(self.linked($.east) && self.linked($.west) && !self.linked($.north) && !self.linked($.south));
    }

    method vertical-passage( --> Bool ) {
        ?(self.linked($.north) && self.linked($.south) && !self.linked($.east) && !self.linked($.west));
    }

    method link( Cell $cell, Bool $bidi = True ) {
        my $neighbor;
        if $.north && $.north === $cell.south {
            $neighbor = $.north;
        }
        elsif $.south && $.south === $cell.north {
            $neighbor = $.south;
        }
        elsif $.east && $.east === $cell.west {
            $neighbor = $.east;
        }
        elsif $.west && $.west === $cell.east {
            $neighbor = $.west;
        }

        if $neighbor {
            $!grid.tunnel-under: $neighbor;
        }
        else {
            callsame;
        }
    }
}


class UnderCell is Cell {
    has OverCell $!over-cell;

    multi method new( OverCell:D $over-cell ) {
        self.bless: :row($over-cell.row), :column($over-cell.column), :$over-cell;
    }

    submethod BUILD(:$!over-cell) {}

    submethod TWEAK {
        if $!over-cell.horizontal-passage {
            self.north = $!over-cell.north;
            $!over-cell.north.south = self;
            self.south = $!over-cell.south;
            $!over-cell.south.north = self;

            self.link: self.north;
            self.link: self.south;
        }
        else {
            self.east = $!over-cell.east;
            $!over-cell.east.west = self;
            self.west = $!over-cell.west;
            $!over-cell.west.east = self;

            self.link: self.west;
            self.link: self.west;
        }
    }

    method horizontal-passage( --> Bool ) {
        ?($.east || $.west);
    }

    method vertical-passage( --> Bool ) {
        ?($.north || $.south);
    }
}