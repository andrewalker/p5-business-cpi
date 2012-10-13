package CPI::Gateway::Test;
# ABSTRACT: Fake gateway

use Moose;
use namespace::autoclean;

extends 'CPI::Gateway::Base';

sub get_hidden_inputs {
    my ( $self, $info ) = @_;

    my @hidden_inputs = (
        receiver_email => $self->receiver_email,
        currency       => $self->currency,
        encoding       => $self->form_encoding,
        payment_id     => $info->{payment_id},
        buyer_name     => $info->{buyer}->name,
        buyer_email    => $info->{buyer}->email,
    );

    my $i = 1;

    foreach my $item (@{ $info->{items} }) {
        push @hidden_inputs,
          (
            "item${i}_id"    => $item->id,
            "item${i}_desc"  => $item->description,
            "item${i}_price" => $item->price,
            "item${i}_qty"   => $item->quantity,
          );
        $i++;
    }

    return @hidden_inputs;
}

# TODO
# use SQLite?
# sub get_notification_details {}
# sub query_transactions {}
# sub get_transaction_details {}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 DESCRIPTION

Used only for testing. See the t/ directory in this distribution.
