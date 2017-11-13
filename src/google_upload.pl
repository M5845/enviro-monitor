#!/usr/bin/env perl

use strict;
use warnings;

use 5.10.00;

use Storable;

use Net::Google::DataAPI::Auth::OAuth2;
use Net::Google::Spreadsheets;
use YAML;

use Data::Dumper;

use POSIX qw(strftime);

use Pod::Usage qw(pod2usage);
use Getopt::Long qw(GetOptions);

pod2usage(
    -message => "\n\tNo arguments\n",
    -verbose => 1
) if ( @ARGV == 0 );

my %opt = (
    "help"   => 0,
    "man"    => 0,
    "input"  => 0,
    "config" => 0
);

GetOptions(
    \%opt,
    'config|c=s',
    'input|i=s',
    'help|h',
    "man|m"
) or pod2usage(2);

pod2usage(1) if $opt{help};
pod2usage(-verbose => 2) if $opt{man};

if (not -e $opt{config}) {
    say STDERR "# Configuration file not found!";
    stop();
}

if (not -e $opt{input}) {
    say STDERR "# CSV file not species or found.";
    stop();
}

my $yaml = YAML::LoadFile($opt{config});

if (not -e $yaml->{session}) {
    say STDERR "# Session file not defined or found.";
    stop();
}

# LOGIN
# --------------------------------------------------------------------
say STDERR "# Google Spreadsheet.";

my $oauth2 = Net::Google::DataAPI::Auth::OAuth2->new(
    client_id      => $yaml->{client_id},
    client_secret  => $yaml->{client_secret},
    scope          => [$yaml->{scope}]
);

my $session = retrieve($yaml->{session});
my $restored_token = Net::OAuth2::AccessToken->session_thaw(
    $session,
    auto_refresh => 1,
    profile => $oauth2->oauth2_webserver,
);
$oauth2->access_token($restored_token);

my $service = Net::Google::Spreadsheets->new(auth => $oauth2);

# Spreadsheet
my $spreadsheet_by_title = $service->spreadsheet({
    title => $yaml->{spreadsheet}
});
say "# Using spreadsheet-id: ". $yaml->{spreadsheet};

# Worksheet
open my $fh, "<", $opt{input} or die "Can't open file for reading: $opt{input}\n";
my @content = <$fh>;

my $worksheet = $yaml->{worksheet};
if ($yaml->{"worksheet-use-date"} && $content[0] =~ /^\d{2}(\d{2})-(\d{2})/) {
    $worksheet = "$1_$2";
}
my $usage_worksheet = $spreadsheet_by_title->worksheet({
    title => $worksheet
});

unless (defined $usage_worksheet) {

    say "# Create new worksheet: $worksheet";
    $usage_worksheet = $spreadsheet_by_title->add_worksheet({
        title => $worksheet
    });

    say "# Adding initial entry";
    $usage_worksheet->batchupdate_cell(
        {col => 1, row => 1, input_value => 'date'},
        {col => 2, row => 1, input_value => 'type'},
        {col => 3, row => 1, input_value => 'id'},
        {col => 4, row => 1, input_value => 'description'},
        {col => 5, row => 1, input_value => 'value'}
    );
} else {
    say "# Appending records to worksheet-id: $worksheet";
}

say "# Connected to Google.";

# Update Worksheet
# --------------------------------------------------------------------
say "# Update Worksheet.";
foreach (@content) {
    chomp;
    say "# Adding entry: $_";
    my @e = split "\t";
    my $new_row = $usage_worksheet->add_row({
        date        => $e[0],
        type        => $e[1],
        id          => $e[2],
        description => $e[3],
        value       => $e[4]
    });
}
close $fh;

say "# Finished.";

__END__

=pod

=head1 INFO

Martin Bens <bensmartin@gmail.com>

=head1 DESCRIPTION

Uploads recodings to google sheet.

=head1 OPTIONS

=over 8

=item B<-config> config.yaml

Config File.

=item B<-input> input.csv

Tab-sep file to upload (cols: data, type, id, description, value)

=back

=head1 LICENCE

GPL-3.0+

=cut

