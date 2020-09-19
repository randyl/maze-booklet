use Grid;

class DistanceGrid is Grid {
    has $.distances is rw;

    method contents-of( $cell ) {
        if $!distances && $!distances{$cell}.defined {
            return $!distances{$cell}.base(36);
        }
        return callsame;
    }
}