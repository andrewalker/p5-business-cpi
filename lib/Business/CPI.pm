package Business::CPI;
# ABSTRACT: Common Payment Interface

use warnings;
use strict;
use Class::Load;

# VERSION

sub new {
    my $class = shift;

    my %data = ref $_[0] && ref $_[0] eq 'HASH' ? %{ $_[0] } : @_;

    my $gateway = delete $data{gateway};
    my $gateway_class = "Business::CPI::Gateway::$gateway";

    Class::Load::load_class($gateway_class);

    return $gateway_class->new(%data);
}

1;

__END__

=head1 SYNOPSIS

    # the objects are created with the same keys
    my $paypal = Business::CPI->new(
        gateway        => "PayPal",
        receiver_email => "test@example.com",
        ...
    );
    my $pagseguro = Business::CPI->new(
        gateway        => "PagSeguro",
        receiver_email => "test@example.com",
        ...
    );

    # the method names and arguments are similar
    my $pag_transactions = $pagseguro->query_transactions({
        start_date => DateTime->now->subtract({ days => 5 }),
        end_date   => DateTime->now,
    });
    my $pay_transactions = $paypal->query_transactions({
        start_date => DateTime->now->subtract({ days => 5 }),
        end_date   => DateTime->now,
    });

=head1 DESCRIPTION

Business::CPI intends to create a common interface between different payment
gateways interfaces. There are on CPAN a few modules which provide interfaces
for payment API's like PayPal (Business::PayPal::*), PagSeguro
(PagSeguro::Status), and so forth. But each of these are completely different.

Business::CPI provides a common interface, making it really easy to support
several payment gateways in a single application.

=method new

Loads and instantiates the gateway. Requires the key 'gateway', and returns the
instance of Business::CPI::Gateway::$gateway. All the other arguments are
passed to the gateway constructor.

Example:

    my $test1 = Business::CPI->new(gateway => 'Test', %data);
    my $test2 = Business::CPI::Gateway::Test->new(%data);     # exactly the same as above

=head1 SPONSORED BY

L<< Aware | http://www.aware.com.br >>

=head1 CAVEATS

This is alpha software. The interface is unstable, and may change without
notice.
