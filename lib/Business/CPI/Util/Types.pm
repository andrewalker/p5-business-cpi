package Business::CPI::Util::Types;
# ABSTRACT: Basic types for Business::CPI
use warnings;
use strict;
use base qw(Exporter);
use Scalar::Util qw/looks_like_number blessed/;
use MooX::Types::MooseLike qw(exception_message);
use MooX::Types::MooseLike::Base;
use Locale::Country ();
use Email::Valid ();

# VERSION

our @EXPORT_OK = qw/to_Money to_PhoneNumber to_Country/;
our %EXPORT_TAGS = (all => \@EXPORT_OK);

MooX::Types::MooseLike::register_types([
    {
        name    => 'Money',
        test    => sub { $_[0] =~ m#^[\d\,]+\.\d{2}$# },
        message => sub { exception_message( $_[0], 'money' ) },
        inflate => 0,
    },
    {
        name    => 'PhoneNumber',
        test    => sub { $_[0] =~ m#^\+?\d+$# },
        message => sub { exception_message( $_[0], 'phone number' ) },
        inflate => 0,
    },
    {
        name    => 'EmailAddress',
        test    => sub { Email::Valid->address($_[0]) },
        message => sub { exception_message( $_[0], 'e-mail address' ) },
        inflate => 0,
    },
    {
        name => 'Country',
        test => sub {
            my $c = $_[0];
            for (Locale::Country::all_country_codes()) {
                return 1 if $_ eq $c;
            }
        },
        message => sub { exception_message( $_[0], '2-letter country code' ) },
        inflate => 0,
    },
    {
        name    => 'DateTime',
        test    => sub { blessed($_[0]) && $_[0]->isa('DateTime') },
        message => sub { exception_message( $_[0], 'DateTime object' ) },
        inflate => 0,
    },
], __PACKAGE__);

sub to_Money {
    my $r = looks_like_number($_[0]) ? $_[0] : 0;
    return sprintf( "%.2f", 0+$r);
}

sub to_PhoneNumber {
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

sub to_Country {
    my $country = lc $_[0];
    for (Locale::Country::all_country_codes()) {
        return $_ if $_ eq $country;
    }
    return Locale::Country::country2code($country);
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
