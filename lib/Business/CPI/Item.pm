package Business::CPI::Item;
# ABSTRACT: Product in the cart
use Moo;
use Business::CPI::Types qw/stringified_money/;

# VERSION

has id => (
    coerce => sub { '' . $_[0] },
    is => 'ro',
    required => 1,
);

has price => (
    coerce => \&stringified_money,
    is => 'ro',
    required => 1,
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
    required => 1,
);

has quantity => (
    coerce => sub { int $_[0] },
    is => 'ro',
    required => 1,
);

1;

__END__

=head1 DESCRIPTION

This class holds information about the products in a shopping cart.

=attr id

B<MANDATORY> - Unique identifier for this product in your application.

=attr price

B<MANDATORY> - The price (in the chosen currency; see
L<Business::CPI::Gateway::Base/currency>) of one item. This will be multiplied
by the quantity.

=attr shipping

The shipping cost (in the chosen currency, same as in the price above) for this
particular item.

=attr shipping_additional

The cost of each additional quantity of this item. For example, if the quantity
is 5, the L</shipping> attribute is set to 1.50, and this attribute is set to
0.50, then the total shipping cost will be 1*1.50 + 4*0.50 = 3.50. Note that
not all gateways implement this. In PayPal, for instance, it's called
shipping2.

=attr weight

The weight of this item. If you define the L</shipping>, this will probably be
ignored by the gateway.

=attr description

B<MANDATORY> - The description or name of the product.

=attr quantity

B<MANDATORY> - How many of this product is being bought?
