package Business::CPI::Role::Cart;
# ABSTRACT: Shopping cart or an order

use Moo::Role;
use Scalar::Util qw/blessed/;
use Carp qw/croak/;
use Business::CPI::Util::Types qw/Money to_Money/;

# VERSION

has id => ( is => 'rw' );
has gateway_id => ( is => 'rw' );

has buyer => (
    is  => 'ro',
    isa => sub {
        $_[0]->does('Business::CPI::Role::Buyer')
          or $_[0]->does('Business::CPI::Role::Account')
          or die "Must implement Business::CPI::Role::Buyer or Business::CPI::Role::Account";
    },
    required => 1,
);

has tax => (
    coerce => \&to_Money,
    isa    => Money,
    is     => 'rw',
);

has handling => (
    coerce => \&to_Money,
    isa    => Money,
    is     => 'rw',
);

has discount => (
    coerce => \&to_Money,
    isa    => Money,
    is     => 'rw',
);

has _gateway => (
    is       => 'ro',
    required => 1,
    isa      => sub {
        $_[0]->isa('Business::CPI::Gateway::Base')
          or die "Must be a Business::CPI::Gateway::Base";
    },
);

has _items => (
    is => 'ro',
    default => sub { [] },
);

has _receivers => (
    is => 'ro',
    default => sub { [] },
);

sub get_item {
    my ($self, $item_id) = @_;

    for (my $i = 0; $i < @{ $self->_items }; $i++) {
        my $item = $self->_items->[$i];
        if ($item->id eq "$item_id") {
            return $item;
        }
    }

    return undef;
}

sub add_item {
    my ($self, $info) = @_;

    if (blessed $info) {
        croak q|Usage: $cart->add_item({ ... })|;
    }

    my $item = $self->_gateway->item_class->new($info);

    push @{ $self->_items }, $item;

    return $item;
}

sub add_receiver {
    my ($self, $info) = @_;

    if (blessed $info) {
        croak q|Usage: $cart->add_receiver({ ... })|;
    }

    my $gateway = $self->_gateway;
    $info->{_gateway} = $gateway;

    my $item = $gateway->receiver_class->new($info);

    push @{ $self->_receivers }, $item;

    return $item;
}

sub get_form_to_pay {
    my ($self, $payment) = @_;

    return $self->_gateway->get_form({
        payment_id => $payment,
        items      => [ @{ $self->_items } ], # make a copy for security
        buyer      => $self->buyer,
        cart       => $self,
    });
}


sub get_checkout_code {
    my ($self, $payment) = @_;

    return $self->_gateway->get_checkout_code({
        payment_id => $payment,
        items      => [ @{ $self->_items } ],
        buyer      => $self->buyer,
        cart       => $self,
    });
}

1;

__END__

=head1 DESCRIPTION

Cart class for holding products to be purchased. Don't instantiate this
directly, use L<Business::CPI::Gateway::Base/new_cart> to build it.

=attr id

The id of the cart, if your application has one set for it.

=attr gateway_id

The id your gateway has set for this cart, if there is one.

=attr buyer

The person paying for the shopping cart. See L<Business::CPI::Role::Buyer> or
L<Business::CPI::Role::Account>.

=attr discount

Discount to be applied to the total amount. Positive number.

=attr tax

Tax to be applied to the total amount. Positive number.

=attr handling

Handling to be applied to the total amount. Positive number.

=method add_item

Create a new L<< Item | Business::CPI::Role::Item >> object with the given
hashref, and add it to cart.

=method get_item

Get item with the given id.

=method get_form_to_pay

Takes a payment_id as the only argument, and returns an L<HTML::Element> form,
to submit to the gateway.

=method get_checkout_code

Very similar to get_form_to_pay, C<< $cart->get_checkout_code >> will send to
the gateway this cart, and return a token for it, so that the payment will be
made referring to this token. It receives the same arguments as
get_form_to_pay.
