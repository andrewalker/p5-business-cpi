package Business::CPI::Cart;
# ABSTRACT: Shopping cart

use Moo;
use Business::CPI::Item;

# VERSION

has buyer => (
    is => 'ro',
    isa => sub { $_[0]->isa('Business::CPI::Buyer') or die "Must be a Business::CPI::Buyer" },
);

has _gateway => (
    is => 'ro',
    isa => sub { $_[0]->isa('Business::CPI::Gateway::Base') or die "Must be a CPI::Gateway::Base" },
);

has _items => (
    is => 'ro',
    #isa => 'ArrayRef[Business::CPI::Item]',
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

    my $item = ref $info && ref $info eq 'Business::CPI::Item' ? $info : Business::CPI::Item->new($info);

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
directly, use L<Business::CPI::Gateway::Base/new_cart> to build it.

=attr buyer

The person paying for the shopping cart. See L<Business::CPI::Buyer>.

=method add_item

Create a new Business::CPI::Item object with the given hashref, and add it to
cart.

=method get_item

Get item with the given id.

=method get_form_to_pay

Takes a payment_id as the only argument, and returns an HTML::Element form, to
submit to the gateway.
