package Business::CPI::Role::Receiver;
# ABSTRACT: The person receiving the money
use utf8;
use Moo::Role;
use MooX::Types::MooseLike::Base qw/Bool/;

# VERSION

has _gateway => (
    is       => 'rw',
    required => 1,
);

has account => (
    is       => 'rw',
    required => 1,
);

has is_primary => (
    is      => 'rw',
    isa     => Bool,
    default => sub { 0 },
);

has fixed_amount   => ( is => 'rw', coerce => sub { 0 + $_[0] } );
has percent_amount => ( is => 'rw', coerce => sub { 0 + $_[0] } );

around BUILDARGS => sub {
    my $orig = shift;
    my $self = shift;

    my $args = $self->$orig(@_);

    # let it die elsewhere
    return $args unless $args->{_gateway};

    if (my $id = delete $args->{gateway_id}) {
        my $acc_class = $args->{_gateway}->account_class;
        $args->{account} = $acc_class->new({ gateway_id => $id });
    }

    return $args;
};

1;

=head1 DESCRIPTION

This role is meant to be included by the class which represents Receivers in
the gateway, such as L<Business::CPI::Base::Receiver>. A Receiver is an account
in the gateway which is going to receive a percentage or fixed amount of the
payment being made.

=head1 SYNOPSIS

    # when building a cart
    my $cart = $cpi->new_cart({
        ...
        receivers => [
            {
                # alias for account.gateway_id
                gateway_id     => 2313,

                fixed_amount   => 50.00,
                percent_amount => 5.00,
            },
            {
                account      => $cpi->account_class->new({ ... }),
                fixed_amount => 250.00,
            },
        ],
    });

=attr account

B<MANDATORY>. A representation of the user account in the gateway. See
L<< the Account role | Business::CPI::Role::Account >> for details.

=attr gateway_id (shortcut)

This is not really an attribute, but a shortcut to the
L<< gateway_id | Business::CPI::Role::Account/gateway_id >>
attribute in the Account. You should provide either a gateway_id or an Account
object (for the account attribute) when instantiating a Receiver object, but
never both.

=attr is_primary

Boolean. Is this the main account receiving the money, or secondary? Defaults
to false, i.e., it's a secondary receiver.

=attr fixed_amount

The value, in the chosen currency, this receiver is getting of the payment.

=attr percentual_amount

The percentage of the payment that this receiver is getting.
