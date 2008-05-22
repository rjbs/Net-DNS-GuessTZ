# These tests are not under ./t because if hosts move, I don't want the dist to
# stop installing. -- rjbs, 2008-05-22
use strict;
use warnings;
use Test::More tests => 9;
use Net::DNS::GuessTZ qw(tz_from_host);

my %data = (
 'rjbs.manxome.org'  => [ 'America/New_York', 'America/New_York' ],

 'www.google.co.uk'  => [ 'America/New_York', 'Europe/London' ], 
 'www.sixapart.jp'   => [ 'America/New_York', 'Asia/Tokyo' ],

 'www.parliament.uk' => [ 'Europe/London',    'Europe/London' ],
);

is_deeply(
  [ Net::DNS::GuessTZ->_all_tz_from_ip('www.parliament.uk') ],
  [ qw(Europe/London) ],
  "parliament is hosted in Blighty",
);

for my $host (sort keys %data) {
  for my $prefer_cc (0, 1) {
    my $have = tz_from_host($host, { prefer_cc => $prefer_cc });
    my $want = $data{ $host }[ $prefer_cc ];

    is($have, $want, "$host, prefer_cc: $want");
  }
}
