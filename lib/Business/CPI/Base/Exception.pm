package Business::CPI::Base::Exception;
# ABSTRACT: General implementation of Item role
use utf8;
use Moo;
with 'Business::CPI::Role::Exception';

# VERSION

1;

=head1 DESCRIPTION

This is the most generic implementation of the L<Business::CPI::Role::Exception>
role. If your driver needs something more specific, it can create a new class
which uses L<< Exception | Business::CPI::Role::Exception >>.

=head1 SEE ALSO

L<Business::CPI::Role::Exception>
