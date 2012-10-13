package CPI::Gateway::Base;
# ABSTRACT: Father of all gateways
use Moose;
use Carp;
use MooseX::Types::Locale::Currency qw( CurrencyCode );
use MooseX::Types::Email qw( EmailAddress );
use CPI::Cart;
use CPI::Buyer;
use HTML::Element;
use namespace::autoclean;

has name => (
    is      => 'ro',
    isa     => 'Str',
    default => sub {
        my $self  = shift;
        my $class = ref $self;
        my @parts = split '::', $class;
        return lc( pop @parts );
    },
);

has receiver_email => (
    isa => EmailAddress,
    is  => 'ro',
);

has currency => (
    isa => CurrencyCode,
    is  => 'ro',
);

has checkout_url => (
    is => 'ro',
    isa => 'Str',
);

has checkout_form_http_method => (
    is => 'ro',
    isa => 'Str',
    default => 'post',
);

has checkout_form_submit_name => (
    is => 'ro',
    isa => 'Str',
    default => 'submit',
);

has checkout_form_submit_value => (
    is => 'ro',
    isa => 'Str',
    default => '',
);

has form_encoding => (
    is      => 'ro',
    isa     => 'Str',
    default => 'UTF-8',
);

# TODO: submit image

around currency => sub {
    my $orig = shift;
    my $self = shift;

    return uc $self->$orig(@_);
};

sub new_cart {
    my ( $self, $info ) = @_;

    my @items =
      map { ref $_ eq 'CPI::Item' ? $_ : CPI::Item->new($_) }
      @{ delete $info->{items} || [] };

    my $buyer = CPI::Buyer->new( delete $info->{buyer} );

    return CPI::Cart->new(
        _gateway => $self,
        _items   => \@items,
        buyer    => $buyer,
    );
}

sub get_hidden_inputs { () }

sub get_form {
    my ($self, $info) = @_;

    my @hidden_inputs = $self->get_hidden_inputs($info);

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

__PACKAGE__->meta->make_immutable;

1;

__END__

=attr name

Name of the gateway (e.g. paypal).

=attr receiver_email

E-mail of the business owner.

=attr currency

Currency code, such as BRL, EUR, USD, etc.

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

Creates a new L<CPI::Cart> connected to this gateway.

=method get_form

Get the form to checkout. Use the method in L<CPI::Cart>, don't use this method
directly.

=method get_notification_details

Get the payment notification (such as PayPal's IPN), and return a hashref with
the details.

=method query_transactions

Search past transactions.

=method get_transaction_details

Get more details about a given transaction.
