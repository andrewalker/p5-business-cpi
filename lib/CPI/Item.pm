package CPI::Item;
# ABSTRACT: Product in the cart
use Moo;

has id => (
    coerce => sub { '' . $_[0] },
    is => 'ro',
);

has price => (
    coerce => sub { 0 + $_[0] },
    is => 'ro',
);

has description => (
    coerce => sub { '' . $_[0] },
    is => 'ro',
);

has quantity => (
    coerce => sub { int $_[0] },
    is => 'ro',
);

around price => sub {
    my $orig = shift;
    my $self = shift;

    return sprintf( "%.2f", $self->$orig(@_) );
};

1;

__END__

=head1 DESCRIPTION

This class holds information about the products in a shopping cart.

=attr id

Unique identifier for this product in your application.

=attr price

The price (in the chosen currency; see L<CPI::Gateway::Base/currency>) of one
item. This will be multiplied by the quantity.

=attr description

The description or name of the product.

=attr quantity

How many of this product is being bought?
