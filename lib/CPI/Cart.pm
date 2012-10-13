package CPI::Cart;
# ABSTRACT: Shopping cart

use Moose;
use CPI::Item;
use namespace::autoclean;

has buyer => (
    is => 'ro',
    isa => 'CPI::Buyer',
);

has _gateway => (
    is => 'ro',
    isa => 'CPI::Gateway::Base',
);

has _items => (
    is => 'ro',
    isa => 'ArrayRef[CPI::Item]',
    traits => [ 'Array' ],
    handles => {
        _add_item  => 'push',
        _get_item  => 'get',
        count      => 'count',
        has_items  => 'count',
        items      => 'elements',
    },
);

sub get_item {
    my ($self, $item_id) = @_;

    for (my $i = 0; $i < $self->count; $i++) {
        my $item = $self->_get_item($i);
        if ($item->id eq "$item_id") {
            return $item;
        }
    }

    return undef;
}

sub add_item {
    my ($self, $info) = @_;

    return $self->_add_item(CPI::Item->new($info));
}

sub get_form_to_pay {
    my ($self, $payment) = @_;

    return $self->_gateway->get_form({
        payment_id => $payment,
        items      => [ $self->items ],
        buyer      => $self->buyer,
    });
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 DESCRIPTION

Cart class for holding products to be purchased. Don't instantiate this
directly, use L<CPI::Gateway::Base/new_cart> to build it.

=method add_item

Create a new CPI::Item object with the given hashref, and add it to cart.

=method get_item

Get item with the given id.

=method get_form_to_pay

Takes a payment_id as the only argument, and returns an HTML::Element form, to
submit to the gateway.
