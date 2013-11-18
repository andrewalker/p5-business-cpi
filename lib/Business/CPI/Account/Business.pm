package Business::CPI::Account::Business;
# ABSTRACT: Business::CPI representation of corporations
use Moo;
use utf8;
use Business::BR::CNPJ ();
use Class::Load ();

# VERSION

has _gateway       => ( is => 'rw' );

has corporate_name => ( is => 'rw' );
has trading_name   => ( is => 'rw' );
has phone          => ( is => 'rw' );

has address => ( is => 'rw' );

around address => sub {
    my $orig = shift;
    my $self = shift;

    if (my $new_address = shift) {
        return $self->$orig( $self->_inflate_addr($new_address) );
    }

    return $self->$orig();
};

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    my $args  = $class->$orig(@_);

    if (exists $args->{address}) {
        $args->{address} = $class->_inflate_address($args->{address}, $args->{_gateway});
    }

    return $args;
};

sub _inflate_address {
    my ($self, $addr, $gateway) = @_;

    if (!$gateway && ref $self) {
        $gateway = $self->_gateway;
    }
    elsif (!$gateway) {
        Class::Load::load_class( "Business::CPI::Account::Address" );
        return Business::CPI::Account::Address->new($addr);
    }

    my $gateway_name = (split /::/, ref $gateway)[-1];
    my $address_class = Class::Load::load_first_existing_class(
        "Business::CPI::Account::Address::$gateway_name",
        "Business::CPI::Account::Address"
    );

    return $address_class->new($addr);
}

1;

=head1 SYNOPSIS

    $cpi->create_account({
        # ...
        business => {
            corporate_name => 'MyCompany Ltd.',
            trading_name   => 'MyCompany',
            phone          => '11 11110000',
            address        => {
                street     => 'Alameda Santos',
                number     => '321',
                complement => '3º andar',
                district   => 'Bairro Y',
                city       => 'São Paulo',
                state      => 'SP',
                country    => 'br',
            },
        },
        # ...
    });

=head1 DESCRIPTION

This class represents information about businesses in the context of accounts
in gateways. You shouldn't have to instantiate this yourself, but use the
helpers provided by the gateway driver.

=attr corporate_name

The complete corporate name of the company.

=attr trading_name

The common trading name as the company is known.

=attr phone

A phone number of the company.

=attr address

See L<Business::CPI::Account::Address>. You should provide a
HashRef with the attributes, according to the
L<< Address | Business::CPI::Account::Address >>
class, and it will be inflated for you.

=method BUILDARGS

Used to inflate C<address> key in the constructor.

=head1 SPONSORED BY

Estante Virtual - L<http://www.estantevirtual.com.br>

=head1 SEE ALSO

L<Business::CPI>, L<Business::CPI::Account>, L<Business::CPI::Account::Address>
