package Business::CPI::Base::Account::Business;
# ABSTRACT: General implementation of Account::Business role
use utf8;
use Moo;
with 'Business::CPI::Role::Account::Business';

# VERSION

1;

=head1 DESCRIPTION

This is the most generic implementation of the
L<Business::CPI::Role::Account::Business> role. If your driver needs something
more specific, it can create a new class which uses
L<< Account::Business | Business::CPI::Role::Account::Business >>.

=head1 SEE ALSO

L<Business::CPI::Role::Account::Business>
