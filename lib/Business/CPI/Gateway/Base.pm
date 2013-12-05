package Business::CPI::Gateway::Base;
# ABSTRACT: Father of all gateways
use Moo;
use Locale::Currency ();
use Data::Dumper;

with 'Business::CPI::Role::Gateway::Base';

# VERSION

has receiver_email => (
    is => 'ro',
);

sub receiver_id { goto \&receiver_email }

has checkout_url => (
    is => 'rw',
);

has checkout_with_token => (
    is => 'ro',
    default => sub { 0 },
);

has currency => (
    isa => sub {
        my $curr = uc($_[0]);

        for (Locale::Currency::all_currency_codes()) {
            return 1 if $curr eq uc($_);
        }

        die "Must be a valid currency code";
    },
    coerce => sub { uc $_[0] },
    is => 'ro',
);

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    my $args  = $class->$orig(@_);

    $args->{receiver_email} = $args->{receiver_id} if $args->{receiver_id};

    return $args;
};

sub new_account {
    my ($self, $account) = @_;

    return $self->account_class->new(
        _gateway => $self,
        %$account
    );
}

sub new_cart {
    my ( $self, $info ) = @_;

    if ($self->log->is_debug) {
        $self->log->debug("Building a cart with: " . Dumper($info));
    }

    my @items     = @{ delete $info->{items}     || [] };
    my @receivers = @{ delete $info->{receivers} || [] };

    my $buyer_class = $self->buyer_class;
    my $cart_class  = $self->cart_class;

    # We might be using a more generic Account class
    if ($buyer_class->does('Business::CPI::Role::Account')) {
        $info->{buyer}{_gateway} = $self;
    }

    $self->log->debug(
        "Loaded buyer class $buyer_class and cart class $cart_class."
    );

    my $buyer = $buyer_class->new( delete $info->{buyer} );

    $self->log->info("Built cart for buyer " . $buyer->email);

    my $cart = $cart_class->new(
        _gateway => $self,
        buyer    => $buyer,
        %$info,
    );

    for (@items) {
        $cart->add_item($_);
    }

    for (@receivers) {
        $cart->add_receiver($_);
    }

    return $cart;
}

sub map_object {
    my ($self, $map, $obj) = @_;

    my @result;

    while (my ($bcpi_key, $gtw_key) = each %$map) {
        my $value = $obj->$bcpi_key;
        next unless $value;

        my $name = $gtw_key;

        if (ref $gtw_key) {
            $name  = $gtw_key->{name};
            $value = $gtw_key->{coerce}->($name);
        }

        push @result, ( $name, $value );
    }

    return @result;
}

sub get_notification_details { shift->_unimplemented }

sub query_transactions { shift->_unimplemented }

sub get_transaction_details { shift->_unimplemented }

sub notify { shift->_unimplemented }

sub get_checkout_code { shift->_unimplemented }

sub _unimplemented {
    my $self = shift;
    die "Not implemented.";
}

1;

__END__

=attr driver_name

The name of the driver for this gateway. This is built automatically, but can
be customized.

Example: for C<Business::CPI::Gateway::TestGateway>, the driver name will be
C<TestGateway>.

=attr log

Provide a logger to the gateway. It's the user's responsibility to configure
the logger. By default, nothing is logged. You could set this to a
L<Log::Log4perl> object, for instance, to get full logging.

=attr item_class

The class for the items (products) being purchased. Defaults to
Business::CPI::${driver_name}::Item if it exists, or
L<Business::CPI::Base::Item> otherwise.

=attr cart_class

The class for the shopping cart (the complete order). Defaults to
Business::CPI::${driver_name}::Cart if it exists, or
L<Business::CPI::Base::Cart> otherwise.

=attr buyer_class

The class for the buyer (the sender). Defaults to
Business::CPI::${driver_name}::Buyer if it exists, or
L<Business::CPI::Base::Buyer> otherwise.

=attr account_class

The class for the accounts. Defaults to Business::CPI::${driver_name}::Account
if it exists, or L<Business::CPI::Base::Account> otherwise.

=attr account_address_class

The class for the addresses for the accounts. Defaults to
Business::CPI::${driver_name}::Account::Address if it exists, or
L<Business::CPI::Base::Account::Address> otherwise.

=attr account_business_class

The class for the business information of accounts. Defaults to
Business::CPI::${driver_name}::Account::Business if it exists, or
L<Business::CPI::Base::Account::Business> otherwise.

=attr receiver_id

ID, login or e-mail of the business owner. The way the gateway uniquely
identifies the account owner.

=attr receiver_email

E-mail of the business owner. Currently, this an alias for receiver_id, for
backcompatibility. The attribute is called C<receiver_email> only because some
gateways set the account identification as the user's e-mail, but that's not
always the case.

=attr currency

Currency code, such as BRL, EUR, USD, etc.

=attr notification_url

The url for the gateway to postback, notifying payment changes.

=attr return_url

The url for the customer to return to, after they finished the payment.

=attr checkout_with_token

Boolean attribute to determine whether the form will hold the entire cart, or
it will use the payment token generated for it. Defaults to false.

=attr checkout_url

The url the application will post the form to. Defined by the gateway.

=method new_cart

Creates a new L<Business::CPI::Role::Cart> connected to this gateway.

=method new_account

Creates a new instance of an account. In general, you shouldn't need to use
this, except for testing. Use C<create_account>, instead, if your driver
provides it.

=method get_checkout_code

Generates a payment token for a given cart. Do not call this method directly.
Instead, see L<Business::CPI::Role::Cart/get_checkout_code>.

=method get_notification_details

Get the payment notification (such as PayPal's IPN), and return a hashref with
the details.

=method query_transactions

Search past transactions.

=method get_transaction_details

Get more details about a given transaction.

=method notify

This is supposed to be called when the gateway sends a notification about a
payment status change to the application. Receives the request as a parameter
(in a CGI-compatible format), and returns data about the payment. The format is
still under discussion, and is soon to be documented.

=method map_object

Helper method for get_hidden_inputs to translate between Business::CPI and the
gateway, using methods like checkout_form_items_map, checkout_form_buyer_map,
etc.

=for Pod::Coverage BUILDARGS
