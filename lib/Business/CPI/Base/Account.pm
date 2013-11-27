package Business::CPI::Base::Account;
# ABSTRACT: General implementation of Account role
use utf8;
use Moo;

# VERSION

with 'Business::CPI::Role::Account';

1;

=head1 DESCRIPTION

This is the most generic implementation of the L<Business::CPI::Role::Account>
role. If your driver needs something more specific, it can create a new class
which uses L<< Account | Business::CPI::Role::Account >>.

=head1 SEE ALSO

L<Business::CPI::Role::Account>
