package Business::CPI::EmptyLogger;
# ABSTRACT: Default null logger
use warnings;
use strict;

# VERSION

sub new      { bless {}, shift }
sub is_debug {}
sub debug    {}
sub info     {}
sub warn     {}
sub error    {}
sub fatal    {}

1;

__END__

=head1 DESCRIPTION

By default, nothing is logged. This class exists just so that, if the user
wants, it can provide his own logger (e.g. Log::Log4perl, Catalyst::Log,
Log::Dispatcher, etc) when building the Business::CPI gateway object, such as:

    my $cpi = Business::CPI->new(
        gateway => 'Test',
        log     => $log,
        ...
    );

=method new

Constructor.

=method is_debug

=method debug

=method info

=method warn

=method error

=method fatal

None of these do anything. It's called by Business::CPI internally, but it's
just a placeholder.
