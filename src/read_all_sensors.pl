#!/usr/bin/env perl

use strict;
use warnings;

use 5.10.00;

use Storable;

use Data::Dumper;
use Net::Google::DataAPI::Auth::OAuth2;
use Net::Google::Spreadsheets;

use POSIX qw(strftime);

use lib '../lib';

use Sensor;

use YAML;

use Pod::Usage qw(pod2usage);
use Getopt::Long qw(GetOptions);

pod2usage(
    -message => "\n\tNo arguments\n",
    -verbose => 1
) if ( @ARGV == 0 );

my %opt = (
    "help" => 0,
    "man"  => 0,
    "config" => 0
);

GetOptions(
    \%opt,
    'config|c=s',
    'help|h',
    "man|m"
) or pod2usage(2);

pod2usage(1) if $opt{help};
pod2usage(-verbose => 2) if $opt{man};

$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;

# known temperature sensors
say STDERR "# Getting sensors information.";

if (not -e $opt{config}) {
    say STDERR "# Sensor information required!";
    stop();
}

my $yaml = YAML::LoadFile($opt{config});

say STDERR "# Reading input.";
my @results;

# Temperature
foreach my $sensor (@$yaml) {

    my $time = strftime "%F %H:%M:%S", localtime;
    my $value = "NA";

    say STDERR "# Reading: $sensor->{id}";

    if ($sensor->{sensor} eq "dallas") {
        $value = dallas_like($sensor->{id});
    } elsif ($sensor->{sensor} eq "AM2302") {
        $value = DHT(0);
    } elsif ($sensor->{sensor} eq "BMP180") {
        $value = BMP108();
    } elsif ($sensor->{sensor} eq "onBoard") {
        $value = piTemp();
    } else {
        say STDERR "# Unknown sensor: " . $sensor->{id};
    }

    push @results, [ $time, $sensor->{type}, $sensor->{id}, $sensor->{cable}, $value ];
}

# STDOUT
say STDERR "# Results:";
for (@results) {
    say join "\t", @$_;
}

say STDERR "# Finished.";

1;

__END__

=pod

=head1 INFO

Martin Bens <bensmartin@gmail.com>

=head1 DESCRIPTION

Reads and prints sensors values for sensors specified in -config file.

=head1 OPTIONS

=over 8

=item B<-config> config.yaml

Config File.

=back

=head1 LICENCE

GPL-3.0+

=cut

