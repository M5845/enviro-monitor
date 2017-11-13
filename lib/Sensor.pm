#!/usr/bin/env perl

=head1 NAME

Sensor - Interface to some RaspberryPi sensors scripts.

=head1 SYNOPSIS

    use Sensor;

=head1 DESCRIPTION

Interface to some scripts reading RaspberryPi sensors.

=head2 Methods

=over 12

=item C<dallas_like>

Returns temperatur from DALLAS sensor.

=item C<DHT>

Returns humidity from DHT sensor.

=item C<BMP108>

Returns pressure from BMP108 sensor.

=item C<piTemp>

Returns onBoard temperature of raspberry.

=back

=head1 LICENSE

GPL-3.0+

=head1 AUTHOR

Martin Bens <bensmartin@gmail.com>

=cut

package Sensor;

use 5.10.00;

use Exporter;

@ISA = ('Exporter');
@EXPORT = ('dallas_like', 'DHT', 'BMP108', 'piTemp');

use Storable;
use Data::Dumper;

# https://github.com/technion/lol_dht22
my $script_dht22 = "/home/elliot/sources/lol_dht22/loldht";

# https://learn.adafruit.com/using-the-bmp085-with-raspberry-pi/using-the-adafruit-bmp-python-library
my $script_bmp = "/home/elliot/sources/Adafruit_Python_BMP/examples/simpletest.py";

sub dallas_like {
    my ($sensor_id) = @_;
    my $output = "NA";
    my $file   = "/sys/bus/w1/devices/$sensor_id/w1_slave";
    unless (-e $file) {
        return $output;
    }

    $output = `cat $file 2>&1`;
    if ( $output =~ /No such/ || $output =~ /NO/ ) {
        $output = "NA";
    } elsif ( $output =~ /t=(.+)/ ) {
        $output = sprintf( "%.1f", $1 / 1000 );
    }

    return $output;
}


sub DHT {
    my ($pin) = @_;
    my @output = `$script_dht22 $pin`;
    my $output = "NA";
    foreach my $line (@output) {
        chomp $line;
        if ($line =~ /^[0-9]/) {
            $output = sprintf( "%.2f", $line );
        }
    }

    return $output;
}

sub BMP108 {
    my @output = `python $script_bmp`;
    my $output = "NA";

    foreach my $line (@output) {
        chomp $line;
        if ($line =~ /^Pressure\s=\s(.+?)\s/) {
            $output = sprintf( "%.2f", $1 );
	}
    }

    return $output;
}

sub piTemp {
     my @output = `vcgencmd measure_temp`;
     my $output = "NA";

     foreach my $line (@output) {
	     chomp $line;
	     if ($line =~ /^temp=(.+?)'C/) {
		     $output = $1;
	     }
     }
     return $output;
}

1;
