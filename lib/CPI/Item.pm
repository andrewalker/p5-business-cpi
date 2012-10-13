package CPI::Item;
# ABSTRACT: Product in the cart
use Moose;
use namespace::autoclean;

has id => (
    isa => 'Str',
    is => 'ro',
);

has price => (
    isa => 'Num',
    is => 'ro',
);

has description => (
    isa => 'Str',
    is => 'ro',
);

has quantity => (
    isa => 'Int',
    is => 'ro',
);

around price => sub {
    my $orig = shift;
    my $self = shift;

    return sprintf( "%.2f", $self->$orig(@_) );
};

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 DESCRIPTION

This class holds information about the products in a shopping cart.
