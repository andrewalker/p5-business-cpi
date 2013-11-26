package Business::CPI::Account;
# ABSTRACT: Manage accounts in the gateway
use Moo;
use utf8;
use DateTime;
use Email::Valid;
use Scalar::Util qw/blessed/;
use Class::Load ();
use Business::CPI::Types qw/is_valid_phone_number phone_number/;

# VERSION

# TODO: Validate this? URI.pm seems to accept anything
# actually... does this really belong here???
has return_url => ( is => 'rw' );

has _gateway => ( is => 'ro', required => 1 );

has id         => ( is => 'rw' );
has gateway_id => ( is => 'rw' );

# Some gateways use the Full Name, others use the first and last separately.
# You can set both and let the driver decide what to send.
has full_name  => ( is => 'lazy' );
has first_name => ( is => 'rw' );
has last_name  => ( is => 'rw' );

has phone => (
    is  => 'rw',
    isa => sub {
        die "Must be in a valid phone number, "
          . "see Business::CPI::Account docs for details"
          unless is_valid_phone_number( $_[0] );
    },
    coerce => \&phone_number
);

has login => ( is => 'rw' );

has email => (
    is => 'rw',
    isa => sub {
        die "Must be a valid e-mail address"
            unless Email::Valid->address( $_[0] );
    }
);

has birthdate => (
    is => 'rw',
    isa => sub {
        die "Must be a DateTime object"
            unless blessed $_[0] && $_[0]->isa('DateTime');
    }
);

has registration_date => (
    is => 'rw',
    isa => sub {
        die "Must be a DateTime object"
            unless blessed $_[0] && $_[0]->isa('DateTime');
    }
);

has is_business_account => ( is => 'rw', coerce => sub { $_[0] ? 1 : 0 } );

has address => ( is => 'rw' );

has business => ( is => 'rw' );

around address => sub {
    my $orig = shift;
    my $self = shift;

    if (my $new_address = shift) {
        return $self->$orig( $self->_inflate_address($new_address) );
    }

    return $self->$orig();
};

around business => sub {
    my $orig = shift;
    my $self = shift;

    if (my $new_business = shift) {
        return $self->$orig( $self->_inflate_business($new_business) );
    }

    return $self->$orig();
};

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    my $args  = $class->$orig(@_);

    return $args if !$args->{_gateway}; # let it die elsewhere

    if (exists $args->{business}) {
        $args->{business} = $class->_inflate_business($args->{business}, $args->{_gateway});
    }

    if (exists $args->{address}) {
        $args->{address} = $class->_inflate_address($args->{address}, $args->{_gateway});
    }

    return $args;
};

sub _build_full_name {
    my $self = shift;

    return $self->first_name . ' ' . $self->last_name;
}

sub _inflate_comp {
    my ($self, $which, $comp, $gateway) = @_;

    my $default_class = "Business::CPI::Account::$which";

    $gateway ||= $self->_gateway;

    my $gateway_name = (split /::/, ref $gateway)[-1];
    my $comp_class = Class::Load::load_first_existing_class(
        "${default_class}::${gateway_name}",
        "${default_class}"
    );

    $comp->{_gateway} = $gateway;

    return $comp_class->new($comp);
}

sub _inflate_address {
    my $self = shift;
    return $self->_inflate_comp("Address", @_);
}

sub _inflate_business {
    my $self = shift;
    return $self->_inflate_comp("Business", @_);
}

1;

=head1 SYNOPSIS

    # build the gateway object
    my $cpi = Business::CPI->new( gateway => 'Whatever', ... );

    # get data of the account about to be created
    # instead of Reseller, it could be a client, or data from a form, etc
    my $row = $db->resultset('Reseller')->find(5324);

    # create the object in the gateway
    $cpi->create_account({
        id         => $row->id,
        first_name => $row->name,
        last_name  => $row->surname,
        email      => $row->email,
        birthdate  => $row->birthdate,
        phone      => $row->phone,
        return_url => $myapp->root_url . '/gateway_account_created',
    });

    # hardcoded data
    $cpi->create_account({
        id         => 43125,
        first_name => 'John',
        last_name  => 'Smith',
        email      => 'john@smith.com',
        birthdate  => DateTime->now->subtract(years => 25),
        phone      => '11 00001111',
        address    => {
            street     => 'Av. Paulista',
            number     => '123',
            complement => '7º andar',
            district   => 'Bairro X',
            city       => 'São Paulo',
            state      => 'SP',
            country    => 'br',
        },
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
        return_url => 'http://mrsmith.com',
    });

=head1 DESCRIPTION

This class is used internally by the gateway to build objects representing a
person's account in the gateway. In general, the end-user shouldn't have to
instantiate this directly, but use the helper methods in the gateway main
class. See the L</SYNOPSIS> for an example, and be sure to check the gateway
driver documentation for specific details and examples.

=attr id

The id of the person who owns this account (or will own it, if it's being
created) in the database of the application using L<Business::CPI>. This is
irrelevant for the gateway, but they store it for an easy way for the
application to associate the gateway accounts to the application records.

=attr gateway_id

The code that uniquely identifies this account in the gateway side.

=attr full_name

Individual's full name. We have both full_name, and first_name and last_name
because some gateways use the former, and some the latter. The application
might set both the separate attributes (first and last) and the single one
(full), and let the driver decide what to use. Or, the application might ignore
this field, and let Business::CPI concatenate first and last names to generate
the full_name.

=attr first_name

Individual's first name.

=attr last_name

Individual's last name.

=attr login

Login of the individual in the gateway.

=attr email

E-mail address of the individual.

=attr phone

Phone number of the individual. You can use + sign to set the country code, and
you can set the area code if you want. You may use non-alphanumerical
characters, such as parenthesis or spaces, but they will be removed. You cannot
use letters.

Examples of valid numbers: "+55 11 98123-4567", "11 98123-4567", "98123-4567".

=attr birthdate

The date the person was born. Must be a DateTime object.

=attr registration_date

The date the account was created. Must be a DateTime object.

=attr is_business_account

Boolean attribute to set whether the account represents an individual person or
a company.

=attr address

See L<Business::CPI::Account::Address>. You should provide a
HashRef with the attributes, according to the
L<< Address | Business::CPI::Account::Address >>
class, and it will be inflated for you.

=attr business

See L<Business::CPI::Account::Business>. You should provide a
HashRef with the attributes, according to the
L<< Business | Business::CPI::Account::Business >>
class, and it will be inflated for you.

=attr return_url

The URL the user will be redirected when the account is created.

=method BUILDARGS

Used to inflate C<address> and C<business> keys in the constructor.

=head1 SPONSORED BY

Estante Virtual - L<http://www.estantevirtual.com.br>

=head1 SEE ALSO

L<Business::CPI>, L<Business::CPI::Account::Address>,
L<Business::CPI::Account::Business>, L<Business::CPI::Buyer>
