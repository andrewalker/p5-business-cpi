package Business::CPI::Base::Account::Address;
# ABSTRACT: General implementation of Account::Address role
use utf8;
use Moo;
with 'Business::CPI::Role::Account::Address';

# VERSION

1;

=head1 DESCRIPTION

This is the most generic implementation of the
L<Business::CPI::Role::Account::Address> role. If your driver needs something
more specific, it can create a new class which uses
L<< Account::Address | Business::CPI::Role::Account::Address >>.

=head1 SEE ALSO

L<Business::CPI::Role::Account::Address>
