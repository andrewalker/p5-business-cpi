package Business::CPI::Role::Receiver;
# ABSTRACT: The person receiving the money
use utf8;
use Moo::Role;
use MooX::Types::MooseLike::Base qw/Bool/;

# VERSION

has gateway_id => (
    is       => 'rw',
    required => 1,
);

has is_primary => (
    is      => 'rw',
    isa     => Bool,
    default => sub { 0 },
);

has fixed_amount   => ( is => 'rw', coerce => sub { 0 + $_[0] } );
has percent_amount => ( is => 'rw', coerce => sub { 0 + $_[0] } );

# XXX
# which is better?
#   has account => ( isa => Account );
# or
#   with 'Business::CPI::Role::Account';

1;

=attr gateway_id

The identification this receiver has in the gateway (his account id, or login,
or e-mail).

=attr is_primary

Boolean. Is this the main account receiving the money, or secondary?

=attr fixed_amount

The value, in the chosen currency, this receiver is getting of the payment.

=attr percentual_amount

The percentage of the payment that this receiver is getting.
