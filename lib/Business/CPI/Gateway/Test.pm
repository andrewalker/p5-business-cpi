package Business::CPI::Gateway::Test;
# ABSTRACT: Fake gateway

use Moo;

# VERSION

extends 'Business::CPI::Gateway::Base';

sub get_hidden_inputs {
    my ( $self, $info ) = @_;

    my $buyer = $info->{buyer};
    my $cart  = $info->{cart};

    my @hidden_inputs = (
        receiver_email => $self->receiver_email,
        currency       => $self->currency,
        encoding       => $self->form_encoding,
        payment_id     => $info->{payment_id},
        buyer_name     => $buyer->name,
        buyer_email    => $buyer->email,
    );

    my %buyer_extra = (
        address_line1    => 'shipping_address',
        address_line2    => 'shipping_address2',
        address_city     => 'shipping_city',
        address_state    => 'shipping_state',
        address_country  => 'shipping_country',
        address_zip_code => 'shipping_zip',
    );

    for (keys %buyer_extra) {
        if (my $value = $buyer->$_) {
            push @hidden_inputs, ( $buyer_extra{$_} => $value );
        }
    }

    my %cart_extra = (
        discount => 'discount_amount',
        handling => 'handling_amount',
        tax      => 'tax_amount',
    );

    for (keys %cart_extra) {
        if (my $value = $cart->$_) {
            push @hidden_inputs, ( $cart_extra{$_} => $value );
        }
    }

    my $i = 1;

    foreach my $item (@{ $info->{items} }) {
        push @hidden_inputs,
          (
            "item${i}_id"    => $item->id,
            "item${i}_desc"  => $item->description,
            "item${i}_price" => $item->price,
            "item${i}_qty"   => $item->quantity,
          );

        if (my $weight = $item->weight) {
            push @hidden_inputs, ( "item${i}_weight" => $weight * 1000 ); # show in grams
        }

        if (my $ship = $item->shipping) {
            push @hidden_inputs, ( "item${i}_shipping" => $ship );
        }

        if (my $ship = $item->shipping_additional) {
            push @hidden_inputs, ( "item${i}_shipping2" => $ship );
        }

        $i++;
    }

    return @hidden_inputs;
}

# TODO
# use SQLite?
# sub get_notification_details {}
# sub query_transactions {}
# sub get_transaction_details {}

1;

__END__

=head1 DESCRIPTION

Used only for testing. See the t/ directory in this distribution.
