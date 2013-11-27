package Business::CPI::Base::Item;
# ABSTRACT: General implementation of Item role
use utf8;
use Moo;
with 'Business::CPI::Role::Item';

# VERSION

1;

=head1 DESCRIPTION

This is the most generic implementation of the L<Business::CPI::Role::Item>
role. If your driver needs something more specific, it can create a new class
which uses L<< Item | Business::CPI::Role::Item >>.

=head1 SEE ALSO

L<Business::CPI::Role::Item>
