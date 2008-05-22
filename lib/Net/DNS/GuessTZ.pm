use strict;
use warnings;
package Net::DNS::GuessTZ;

use DateTime::TimeZone 0.51;
use List::Util ();

use Sub::Exporter::Util;
use Sub::Exporter -setup => {
  exports => [ tz_from_host => Sub::Exporter::Util::curry_class ],
};

my $ICF;
sub _icf {
  $ICF ||= do {
    require IP::Country::Fast;
    IP::Country::Fast->new;
  };
}

sub _all_tz_from_cctld {
  my ($self, $host) = @_;
  return unless my ($cctld) = $host =~ /\.(\w{2})\z/;
  DateTime::TimeZone->names_in_country($cctld);
}

sub _all_tz_from_ip {
  my ($self, $host) = @_;
  return unless my $cc = $self->_icf->inet_atocc($host);
  my @names = DateTime::TimeZone->names_in_country($cc);
}

sub tz_from_host {
  my ($self, $host, $arg) = @_;
  $arg ||= {};
  $arg->{ip_country} = 1 ; #unless exists $arg->{ip_country};

  my %result;

  my @names = $self->_all_tz_from_cctld($host);
  $result{cc} = $names[0] if @names; # and @names <= 3;

  if ($arg->{ip_country}) {
    my @names = $self->_all_tz_from_ip($host);
    $result{ip} = $names[0] if @names; # if @names <= 3;
  }

  my @cand = $arg->{prefer_cc} ? @result{qw(cc ip)} : @result{qw(ip cc)};

  if (my $tz = List::Util::first { defined } @cand) {
    return $tz;
  } else {
    return;
  }
}

1;
