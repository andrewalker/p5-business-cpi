package Business::CPI::Role::Item;
# ABSTRACT: Role to represent a product in the cart
use Moo::Role;
use Business::CPI::Util::Types qw/Money/;
use Types::Standard qw/Str Int Num/;

# VERSION

has id => (
    coerce   => Str->coercion,
    isa      => Str,
    is       => 'ro',
    required => 1,
);

has price => (
    coerce   => Money->coercion,
    isa      => Money,
    is       => 'ro',
    required => 1,
);

has weight => (
    coerce => Num->coercion,
    isa    => Num,
    is     => 'ro',
);

has shipping => (
    coerce    => Money->coercion,
    isa       => Money,
    is        => 'ro',
    predicate => 1,
);

has shipping_additional => (
    coerce    => Money->coercion,
    isa       => Money,
    is        => 'ro',
    predicate => 1,
);

has description => (
    coerce => Str->coercion,
    isa    => Str,
    is     => 'ro',
);

has quantity => (
    coercion => Int->coercion,
    isa     => Int,
    is      => 'ro',
    default => sub { 1 },
);

1;

__END__

=head1 DESCRIPTION

This class holds information about the products in a shopping cart.

=attr id

B<MANDATORY> - Unique identifier for this product in your application.

=attr description

A longer description of the product, or just the name, if the gateway doesn't
differentiate between name and description.

=attr price

B<MANDATORY> - The price (in the chosen currency; see
L<Business::CPI::Gateway::Base/currency>) of one item. This will be multiplied
by the quantity.

=attr quantity

How many of this product is being bought? Defaults to 1.

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

=method has_shipping

Predicate for shipping attribute.

=method has_shipping_additional

Predicate for shipping_additional attribute.
