package Business::CPI::Base::Receiver;
# ABSTRACT: General implementation of Receiver role
use utf8;
use Moo;

with 'Business::CPI::Role::Receiver';

# VERSION

1;

=head1 DESCRIPTION

This is the most generic implementation of the L<Business::CPI::Role::Receiver>
role. If your driver needs something more specific, it can create a new class
which uses L<< Receiver | Business::CPI::Role::Receiver >>.

=head1 SEE ALSO

L<Business::CPI::Role::Receiver>

=for Pod::Coverage BUILDARGS
