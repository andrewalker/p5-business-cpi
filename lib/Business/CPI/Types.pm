package Business::CPI::Types;
use warnings;
use strict;
use Exporter 'import';

our @EXPORT_OK = qw/stringified_money/;

sub stringified_money { $_[0] ? sprintf( "%.2f", 0 + $_[0] ) : $_[0] }

1;
