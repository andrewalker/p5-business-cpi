package CPI::Item;
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

=encoding utf8

=head1 NAME

CPI::Item

=head1 DESCRIPTION

This class holds information about the products in a shopping cart.

=head1 CAVEATS

This is alpha software. The interface is unstable, and may change without
notice.

=head1 AUTHOR

André Walker

=head1 LICENSE

This library is free software. You can redistribute it and/or modify it under
the same terms as Perl itself.
