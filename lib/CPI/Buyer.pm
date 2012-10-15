package CPI::Buyer;
use Moo;

has email => (
    isa => sub {
        Email::Valid->address( $_[0] ) || die "Must be a valid e-mail address";
    },
    is => 'ro',
);

has name => (
#    isa => 'Str',
    is => 'ro',
);

# TODO
# add all the other attrs.
#
# try and find the common ones between PagSeguro / PayPal / etc, and keep them
# here. Specific attrs can stay in CPI::Buyer::${gateway}

1;

__END__

=head1 DESCRIPTION

This class holds information about the buyer in a shopping cart.

=attr email

Buyer's e-mail, which usually is their unique identifier in the gateway.

=attr name

Buyer's name.
