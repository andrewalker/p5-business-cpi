package Business::CPI::Types;
# ABSTRACT: Coersion and checks
use warnings;
use strict;
use Exporter 'import';
use Scalar::Util qw/looks_like_number/;

# VERSION

our @EXPORT_OK = qw/stringified_money/;

sub stringified_money {
    my $r = looks_like_number($_[0]) ? $_[0] : 0;
    return sprintf( "%.2f", 0+$r);
}

1;

__END__

=head1 DESCRIPTION

Coersions for the internal CPI attributes.

=method stringified_money

Most gateways require the money amount to be provided with two decimal places.
This method coerces the value into number, and then to a string as expected by
the gateways.
