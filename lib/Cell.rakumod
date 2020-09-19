use Distances;

class Cell {
    has $.row is required;
    has $.column is required;
    has $.north is rw = Cell;
    has $.south is rw = Cell;
    has $.east is rw = Cell;
    has $.west is rw = Cell;
    has $.contents is rw;
    has %!links{Cell};

    method link(Cell $cell, Bool $bidi = True) {
        %!links{$cell} = True;
        $cell.link(self, False) if $bidi;
        self;
    }

    method unlink(Cell $cell, Bool $bidi = True) {
        %!links{$cell}:delete;
        $cell.unlink($cell, False) if $bidi;
        self;
    }

    method links(--> Seq) {
        %!links.keys;
    }

    method linked(Cell $cell --> Bool) {
        return False unless $cell.defined;
        return %!links{$cell}:exists;
    }

    method neighbors(--> Seq) {
        return ($.north, $.south, $.east, $.west).grep: *.defined;
    }

    method distances(--> Distances) {
        my $distances = Distances.new: :root(self);
        my @frontier = [self];

        while @frontier.elems {
            my @new_frontier;

            for @frontier -> Cell $cell {
                for $cell.links -> Cell $linked {
                    next if $distances{$linked}.defined;
                    $distances{$linked} = $distances{$cell} + 1;
                    @new_frontier.push: $linked;
                }
            }

            @frontier = @new_frontier;
        }

        return $distances;
    }

    method Str {
        self.gist;
    }

    method gist {
        "{self.^name}:{ self.row },{ self.column }";
    }
}