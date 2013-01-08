package Business::CPI::Item;
# ABSTRACT: Product in the cart
use Moo;
use Business::CPI::Types qw/stringified_money/;

# VERSION

has id => (
    coerce => sub { '' . $_[0] },
    is => 'ro',
);

has price => (
    coerce => \&stringified_money,
    is => 'ro',
);

has weight => (
    coerce => sub { 0 + $_[0] },
    required => 0,
    is => 'ro',
);

has shipping => (
    coerce => \&stringified_money,
    required => 0,
    is => 'ro',
);

has shipping_additional => (
    coerce => \&stringified_money,
    required => 0,
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

1;

__END__

=head1 DESCRIPTION

This class holds information about the products in a shopping cart.

=attr id

Unique identifier for this product in your application.

=attr price

The price (in the chosen currency; see
L<Business::CPI::Gateway::Base/currency>) of one item. This will be multiplied
by the quantity.

=attr description

The description or name of the product.

=attr quantity

How many of this product is being bought?
