package CPI::Buyer;
use Moose;
use namespace::autoclean;

has email => (
    isa => 'Str',
    is => 'ro',
);

has name => (
    isa => 'Str',
    is => 'ro',
);

# TODO
# add all the other attrs.
#
# try and find the common ones between PagSeguro / PayPal / etc, and keep them
# here. Specific attrs can stay in CPI::Buyer::${gateway}

__PACKAGE__->meta->make_immutable;

1;

__END__

=encoding utf8

=head1 NAME

CPI::Buyer

=head1 DESCRIPTION

This class holds information about the buyer in a shopping cart.

=head1 CAVEATS

This is alpha software. The interface is unstable, and may change without
notice.

=head1 AUTHOR

André Walker

=head1 LICENSE

This library is free software. You can redistribute it and/or modify it under
the same terms as Perl itself.
