package CPI::Cart;
# ABSTRACT: Shopping cart

use Moo;
use CPI::Item;

has buyer => (
    is => 'ro',
    isa => sub { $_[0]->isa('CPI::Buyer') or die "Must be a CPI::Buyer" },
);

has _gateway => (
    is => 'ro',
    isa => sub { $_[0]->isa('CPI::Gateway::Base') or die "Must be a CPI::Gateway::Base" },
);

has _items => (
    is => 'ro',
    #isa => 'ArrayRef[CPI::Item]',
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

    my $item = ref $info && ref $info eq 'CPI::Item' ? $info : CPI::Item->new($info);

    push @{ $self->_items }, $item;

    return $item;
}

sub get_form_to_pay {
    my ($self, $payment) = @_;

    return $self->_gateway->get_form({
        payment_id => $payment,
        items      => [ @{ $self->_items } ], # make a copy for security
        buyer      => $self->buyer,
    });
}

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
