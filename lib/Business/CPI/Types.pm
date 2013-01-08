package Business::CPI::Types;
use warnings;
use strict;
use Exporter 'import';

our @EXPORT_OK = qw/stringified_money/;

sub stringified_money { $_[0] ? sprintf( "%.2f", 0 + $_[0] ) : $_[0] }

1;

__END__

=head1 DESCRIPTION

Coersions for the internal CPI attributes.

=method stringified_money

Most gateways require the money amount to be provided with two decimal places.
This method coerces the value into number, and then to a string as expected by
the gateways.
