#!/usr/bin/env perl

use strict;
use warnings;

use 5.10.00;

use Storable;

use Net::Google::DataAPI::Auth::OAuth2;
use Net::Google::Spreadsheets;

use Data::Dumper;
use POSIX qw(strftime);

use YAML;

use Pod::Usage qw/pod2usage/;
use Getopt::Long qw/GetOptions/;

pod2usage(
    -message => "\n\tNo arguments\n",
    -verbose => 1
) if ( @ARGV != 1 );

my %opt = (
    "help" => 0,
    "man" => 0
);

GetOptions(
    \%opt,
    'config|c=s',
    'help|h',
    "man|m"
) or pod2usage(2);

pod2usage(1) if $opt{help};
pod2usage(-verbose => 2) if $opt{man};

my $yaml = YAML::LoadFile($opt{config});

my $oauth2 = Net::Google::DataAPI::Auth::OAuth2->new(
    client_id     => $yaml->{client_id},
    client_secret => $yaml->{client_secret},
    scope         => [ $yaml->{scope} ],
    redirect_uri  => "urn:ietf:wg:oauth:2.0:oob"
);

my $url = $oauth2->authorize_url();

say "Please visit:\n\t$url\n";

my $code = prompt('x', 'paste the code: ', '', '');

my $token = $oauth2->get_access_token($code) or die;
my $session = $token->session_freeze;

# save the session which can be restored later
store($session, $yaml->{session});

__END__

=pod

=head1 INFO

Martin Bens <bensmartin@gmail.com>

=head1 DESCRIPTION

Creates and stores google session.

=head1 OPTIONS

=over 8

=item B<-config> config.yaml

Config File.

=back

=head1 LICENCE

GPL-3.0+

=cut

