package Business::CPI::Util::EmptyLogger;
# ABSTRACT: Default null logger
use warnings;
use strict;

# VERSION

sub new      { bless {}, shift }

sub debug    {}
sub info     {}
sub warn     {}
sub error    {}
sub fatal    {}

sub is_debug {}
sub is_info  {}
sub is_warn  {}
sub is_error {}
sub is_fatal {}

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

=method debug

=method info

=method warn

=method error

=method fatal

None of these do anything. It's called by Business::CPI internally, but it's
just a placeholder.

=method is_debug

=method is_info

=method is_warn

=method is_error

=method is_fatal

All return false by default.
