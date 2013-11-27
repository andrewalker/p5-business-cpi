package Business::CPI::Base::Cart;
# ABSTRACT: General implementation of Cart role
use utf8;
use Moo;
with 'Business::CPI::Role::Cart';

# VERSION

1;

=head1 DESCRIPTION

This is the most generic implementation of the L<Business::CPI::Role::Cart>
role. If your driver needs something more specific, it can create a new class
which uses L<< Cart | Business::CPI::Role::Cart >>.

=head1 SEE ALSO

L<Business::CPI::Role::Cart>
