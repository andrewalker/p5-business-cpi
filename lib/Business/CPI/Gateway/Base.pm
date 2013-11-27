package Business::CPI::Gateway::Base;
# ABSTRACT: Father of all gateways
use Moo;
use Locale::Currency ();
use Business::CPI::Util;
use Business::CPI::Util::EmptyLogger;
use HTML::Element;
use Data::Dumper;

# VERSION

has driver_name => (
    is      => 'ro',
    default => sub { ( split /::/, ref $_[0] )[-1] },
);

has receiver_email => (
    is => 'ro',
);

sub receiver_id { goto \&receiver_email }

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

has log => (
    is => 'ro',
    default => sub { Business::CPI::Util::EmptyLogger->new },
);

has checkout_with_token => (
    is => 'ro',
    default => sub { 0 },
);

has checkout_url => (
    is => 'rw',
);

has checkout_form_http_method => (
    is => 'ro',
    default => sub { 'post' },
);

has checkout_form_submit_name => (
    is => 'ro',
    default => sub { 'submit' },
);

has checkout_form_submit_value => (
    is => 'ro',
    default => sub { '' },
);

has checkout_form_submit_image => (
    is => 'ro',
    default => sub { '' },
);

has form_encoding => (
    is      => 'ro',
    # TODO: use Encode::find_encoding()
    default => sub { 'UTF-8' },
);

has item_class => (
    is => 'lazy',
    default => sub { shift->_load_class('Item') },
);

has cart_class => (
    is => 'lazy',
    default => sub { shift->_load_class('Cart') },
);

has buyer_class => (
    is => 'lazy',
    default => sub { shift->_load_class('Buyer') },
);

has account_class => (
    is => 'lazy',
    default => sub { shift->_load_class('Account') },
);

has account_address_class => (
    is => 'lazy',
    default => sub { shift->_load_class('Account::Address') },
);

has account_business_class => (
    is => 'lazy',
    default => sub { shift->_load_class('Account::Business') },
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

    my @items = @{ delete $info->{items} || [] };

    my $buyer_class = $self->buyer_class;
    my $cart_class  = $self->cart_class;

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

sub _get_hidden_inputs_for_cart {
    my ($self, $cart) = @_;

    return $self->map_object( $self->_checkout_form_cart_map, $cart );
}

sub _get_hidden_inputs_for_buyer {
    my ($self, $buyer) = @_;

    return $self->map_object( $self->_checkout_form_buyer_map, $buyer );
}

sub _get_hidden_inputs_for_items {
    my ($self, $items) = @_;
    my @result;
    my $i = 1;

    for my $item (@$items) {
        push @result,
          $self->map_object( $self->_checkout_form_item_map( $i++ ), $item );
    }

    return @result;
}

sub _get_hidden_inputs_main {
    my $self = shift;

    return $self->map_object( $self->_checkout_form_main_map, $self );
}

sub get_hidden_inputs { shift->_unimplemented }

sub get_form {
    my ($self, $info) = @_;

    $self->log->info("Get form for payment " . $info->{payment_id});

    my @hidden_inputs = $self->get_hidden_inputs($info);

    if ($self->log->is_debug) {
        $self->log->debug("Building form with inputs: " . Dumper(\@hidden_inputs));
        $self->log->debug("form action => " . $self->checkout_url);
        $self->log->debug("form method => " . $self->checkout_form_http_method);
    }

    my $form = HTML::Element->new(
        'form',
        action => $self->checkout_url,
        method => $self->checkout_form_http_method,
    );

    while (@hidden_inputs) {
        $form->push_content(
            HTML::Element->new(
                'input',
                type  => 'hidden',
                value => pop @hidden_inputs,
                name  => pop @hidden_inputs
            )
        );
    }

    my %submit = (
        name  => $self->checkout_form_submit_name,
        type  => 'submit',
    );

    if (my $value = $self->checkout_form_submit_value) {
        $submit{value} = $value;
    }

    if (my $src = $self->checkout_form_submit_image) {
        $submit{src}  = $src;
        $submit{type} = 'image';
    }

    $form->push_content(
        HTML::Element->new( 'input', %submit )
    );

    return $form;
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

sub _load_class {
    Business::CPI::Util::load_class(shift->driver_name, @_);
}

1;

__END__

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

=attr log

Provide a logger to the gateway. It's the user's responsibility to configure
the logger. By default, nothing is logged.

=attr notification_url

The url for the gateway to postback, notifying payment changes.

=attr return_url

The url for the customer to return to, after they finished the payment.

=attr checkout_with_token

Boolean attribute to determine whether the form will hold the entire cart, or
it will use the payment token generated for it. Defaults to false.

=attr checkout_url

The url the application will post the form to. Defined by the gateway.

=attr checkout_form_http_method

Defaults to post.

=attr checkout_form_submit_name

Defaults to submit.

=attr checkout_form_submit_value

Defaults to ''.

=attr checkout_form_submit_image

If set, makes the submit button become an image. Set this to the URL of the
image you want to display in the checkout button. Defaults to '' (i.e., no
image, default brower submit button).

=attr form_encoding

Defaults to UTF-8.

=method BUILDARGS

Simply makes the receiver_id alias work.

=method new_cart

Creates a new L<Business::CPI::Role::Cart> connected to this gateway.

=method new_account

Creates a new instance of an account. In general, you shouldn't need to use
this, except for testing. Use C<create_account>, instead, if your driver
provides it.

=method get_form

Get the form to checkout. Use the method in L<Business::CPI::Role::Cart>, don't use
this method directly.

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

=method get_hidden_inputs

This method is called when building the checkout form. It will return a hashref
with the field names and field values for the form. This way the gateway will
implement only this method, while the rest of the form will be built by this
class.

=method notify

This is supposed to be called when the gateway sends a notification about a
payment status change to the application. Receives the request as a parameter
(in a CGI-compatible format), and returns data about the payment. The format is
still under discussion, and is soon to be documented.

=method map_object

Helper method for get_hidden_inputs to translate between Business::CPI and the
gateway, using methods like checkout_form_items_map, checkout_form_buyer_map,
etc.
