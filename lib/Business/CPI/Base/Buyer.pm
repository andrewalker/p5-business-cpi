package Business::CPI::Base::Buyer;
# ABSTRACT: General implementation of Buyer role
use utf8;
use Moo;

with 'Business::CPI::Role::Buyer';

# VERSION

1;

=head1 DESCRIPTION

This is the most generic implementation of the L<Business::CPI::Role::Buyer>
role. If your driver needs something more specific, it can create a new class
which uses L<< Buyer | Business::CPI::Role::Buyer >>.

=head1 SEE ALSO

L<Business::CPI::Role::Buyer>
