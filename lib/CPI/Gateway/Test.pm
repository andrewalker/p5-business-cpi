package CPI::Gateway::Test;
use Moose;
use namespace::autoclean;
use HTML::Element;

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

=encoding utf8

=head1 NAME

CPI::Gateway::Test - Fake gateway

=head1 DESCRIPTION

Used only for testing. See the t/ directory in this distribution.

=head1 CAVEATS

This is alpha software. The interface is unstable, and may change without
notice.

=head1 AUTHOR

André Walker

=head1 LICENSE

This library is free software. You can redistribute it and/or modify it under
the same terms as Perl itself.
