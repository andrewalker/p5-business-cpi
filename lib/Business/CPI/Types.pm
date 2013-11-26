package Business::CPI::Types;
# ABSTRACT: Coersion and checks
use warnings;
use strict;
use Exporter 'import';
use Scalar::Util qw/looks_like_number/;

# VERSION

our @EXPORT_OK = qw/stringified_money is_valid_phone_number phone_number/;

sub stringified_money {
    my $r = looks_like_number($_[0]) ? $_[0] : 0;
    return sprintf( "%.2f", 0+$r);
}

sub is_valid_phone_number {
    return $_[0] =~ m#^\+?\d+$#;
}

sub phone_number {
    # avoid warnings
    return unless defined $_[0];

    # force it to stringify
    my $r = "$_[0]";

    # Remove anything that is not alphanumerical or "+"
    # Note that we are using \w instead of \d here, because this sub is used
    # only for coersion. We don't want to remove letters from the phone number,
    # we want it to fail in the `is_valid_phone_number` routine.
    $r =~ s{[^\+\w]}{}g;

    return $r;
}

1;

__END__

=head1 DESCRIPTION

Coersions and validations for the internal CPI attributes.

=method stringified_money

Most gateways require the money amount to be provided with two decimal places.
This method coerces the value into number, and then to a string as expected by
the gateways.

Examples:

=over

=item 5.55 becomes "5.55"

=item 5.5 becomes "5.50"

=item 5 becomes "5.00"

=back

=method is_valid_phone_number

Checks whether the phone number is in the correct format (+9999...).

=method phone_number

Coerces phone numbers to contain an optional + sign in the beginning,
indicating whether it contains the country code or not, and numbers only.
Examples of accepted phone numbers, and their coerced values are:

=over

=item "+55 11 12345678" becomes "+551112345678"

=item "+55 (11) 12345678" becomes "+551112345678"

=item "+551112345678" remains the same

=item "1234-5678" becomes "12345678"

=item "(11)1234-5678" becomes "1112345678"

=item "1234567890123" remains the same

=back
