class Distances {
    has $.root is required;
    has %!cells{Any};  # Would like to use Cell type, but it creates circular dependency.

    submethod TWEAK {
        %!cells{$!root} = 0;
    }

    method cells {
        %!cells.keys;
    }

    method path-to( $goal --> Distances ) {
        my $current = $goal;

        my $breadcrumbs = Distances.new: :$!root;
        $breadcrumbs{$current} = self{$current};

        until $current === $!root {
            for $current.links -> $neighbor {
                if %!cells{$neighbor} < %!cells{$current} {
                    $breadcrumbs{$neighbor} = %!cells{$neighbor};
                    $current = $neighbor;
                    last;
                }
            }
        }

        return $breadcrumbs;
    }

    method max( --> Pair ) {
        %!cells.maxpairs.tail;
    }

    multi method AT-KEY(::?CLASS:D: $key) is rw {
        %!cells{$key};
    }

    multi method EXISTS-KEY (::?CLASS:D: $key) {
        %!cells{$key}:exists;
    }

    multi method DELETE-KEY (::?CLASS:D: $key) {
        %!cells{$key}:delete;
    }

    multi method ASSIGN-KEY (::?CLASS:D: $key, $new) {
        %!cells{$key} = $new;
    }
}