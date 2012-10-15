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
