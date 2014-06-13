package Business::CPI::Base::Status;
# ABSTRACT: General implementation of Status role
use utf8;
use Moo;
with 'Business::CPI::Role::Status';

# VERSION

1;

=head1 DESCRIPTION

This is the most generic implementation of the L<Business::CPI::Role::Status>
role. If your driver needs something more specific, it can create a new class
which uses L<< Status | Business::CPI::Role::Status >>.

=head1 SEE ALSO

L<Business::CPI::Role::Status>
