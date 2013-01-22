package Business::CPI::Gateway::Base;
# ABSTRACT: Father of all gateways
use Moo;
use Locale::Currency ();
use Email::Valid ();
use Business::CPI::Cart;
use Business::CPI::Buyer;
use Business::CPI::EmptyLogger;
use HTML::Element;
use Data::Dumper;

# VERSION

has receiver_email => (
    isa => sub {
        die "Must be a valid e-mail address"
            unless Email::Valid->address( $_[0] );
    },
    is => 'ro',
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

has log => (
    is => 'ro',
    default => sub { Business::CPI::EmptyLogger->new },
);

has checkout_url => (
    is => 'ro',
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

has form_encoding => (
    is      => 'ro',
    # TODO: use Encode::find_encoding()
    default => sub { 'UTF-8' },
);

# TODO: submit image

sub new_cart {
    my ( $self, $info ) = @_;

    if ($self->log->is_debug) {
        $self->log->debug("Building a cart with: " . Dumper($info));
    }

    my @items =
      map { ref $_ eq 'Business::CPI::Item' ? $_ : Business::CPI::Item->new($_) }
      @{ delete $info->{items} || [] };

    my $buyer = Business::CPI::Buyer->new( delete $info->{buyer} );

    $self->log->info("Built cart for buyer " . $buyer->email);

    return Business::CPI::Cart->new(
        _gateway => $self,
        _items   => \@items,
        buyer    => $buyer,
        %$info,
    );
}

sub get_hidden_inputs { () }

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

    my @value = ();
    if (my $value = $self->checkout_form_submit_value) {
        @value = (value => $value);
    }

    $form->push_content(
        HTML::Element->new(
            'input',
            type  => 'submit',
            name  => $self->checkout_form_submit_name,
            @value
        )
    );

    return $form;
}

sub get_notification_details {}

sub query_transactions {}

sub get_transaction_details {}

sub notify {}

1;

__END__

=attr receiver_email

E-mail of the business owner.

=attr currency

Currency code, such as BRL, EUR, USD, etc.

=attr log

Provide a logger to the gateway. It's the user's responsibility to configure
the logger. By default, nothing is logged.

=attr notification_url

The url for the gateway to postback, notifying payment changes.

=attr return_url

The url for the customer to return to, after they finished the payment.

=attr checkout_url

The url the application will post the form to. Defined by the gateway.

=attr checkout_form_http_method

Defaults to post.

=attr checkout_form_submit_name

Defaults to submit.

=attr checkout_form_submit_value

Defaults to ''.

=attr form_encoding

Defaults to UTF-8.

=method new_cart

Creates a new L<Business::CPI::Cart> connected to this gateway.

=method get_form

Get the form to checkout. Use the method in L<Business::CPI::Cart>, don't use
this method directly.

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
