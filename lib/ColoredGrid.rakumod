use Grid;
use Distances;
use Cell;

class ColoredGrid is Grid {
    has Distances $.distances is rw;
    has Int $!maximum;

    method background-color-for( Cell $cell --> Str ) {
        if (not defined $!maximum) {
            $!maximum = $!distances.max.value;
        }

        my $distance = $!distances{$cell};
        return Nil unless $distance;

        my $intensity = ($!maximum - $distance) / $!maximum;
        my $dark = (255 * $intensity).round;
        my $bright = 128 + (127 * $intensity).round;

        return "rgb($dark, $bright, $dark)";
    }
}