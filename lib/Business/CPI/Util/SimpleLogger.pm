package Business::CPI::Util::SimpleLogger;
# ABSTRACT: Default simple logger
use warnings;
use strict;

# VERSION

my %LEVEL = (
    fatal  => 10,
    error  => 20,
    warn   => 30,
    info   => 40,
    debug  => 50
);

sub new      {
    my ($class, %opts) = @_;
    my $self = {
        level => 30 # warn by default
    };
    bless ($self, $class);
    $self->set_level($opts{level}) if exists $opts{level};
    return $self;
}

sub set_level {
    my ($self, $levelstr) = @_;
    if (defined $levelstr and exists $LEVEL{$levelstr}) {
        $self->{level} = $LEVEL{$levelstr};
    }
}

sub debug  { my $self = shift; if ($self->is_debug) { $self->_log_it ('debug', @_); } };
sub info   { my $self = shift; if ($self->is_info ) { $self->_log_it ('info', @_); } };
sub warn   { my $self = shift; if ($self->is_warn ) { $self->_log_it ('warn', @_); } };
sub error  { my $self = shift; if ($self->is_error) { $self->_log_it ('error', @_); } };
sub fatal  { my $self = shift; if ($self->is_fatal) { $self->_log_it ('fatal', @_); } };

sub _log_it  {
    my $self = shift;
    my $level = shift;
    my $msg = uc ("$level: ") . join ("\n", @_);
    if ($level eq 'fatal') {
        die $msg;
    } else {
        CORE::warn $msg;
    }
}

sub is_debug { my $self = shift; return ($self->{level} >= $LEVEL{debug}); }
sub is_info  { my $self = shift; return ($self->{level} >= $LEVEL{info} ); }
sub is_warn  { my $self = shift; return ($self->{level} >= $LEVEL{warn} ); }
sub is_fatal { my $self = shift; return ($self->{level} >= $LEVEL{fatal}); }
sub is_error { my $self = shift; return ($self->{level} >= $LEVEL{error}); }

1;

__END__

=head1 DESCRIPTION

In most cases the user will want to specify their own logger
(e.g. Log::Log4perl, Catalyst::Log, Log::Dispatcher, etc) when building
the Business::CPI gateway object, such as:

    my $cpi = Business::CPI->new(
        gateway => 'Test',
        log     => $log,
        ...
    );

This class exists just so that if the user does not want to do
that there is a simple logger by default which can handle the logging
in a basic manner. It uses these verbosity levels in increasing order:
'fatal', 'error', 'warn', 'info', 'debug'. 

=method new

The constructor accepts an optional hash of options. The only such
option at present is level which sets the default verbosity level. If no
value is specified for this, it defaults to "warn".

    my $log = Business::CPI::Util::SimpleLogger->new(level => 'debug');

=method set_level

Change the current verbosity level to that specified by the string
argument.

    $log->set_level('info');

=method debug

Log a message, but only if the level is set to 'debug'.

=method info

Log a message, but only if the level is set to 'info' or higher.

=method warn

Log a message, but only if the level is set to 'warn' or higher.

=method error

Log a message, but only if the level is set to 'error' or higher.

=method fatal

Log a message and die.

=method is_debug

Returns true if the level is such that a call to the debug method will
log a message, otherwise false.

=method is_info

Returns true if the level is such that a call to the info method will
log a message, otherwise false.

=method is_warn

Returns true if the level is such that a call to the warn method will
log a message, otherwise false.

=method is_error

Returns true if the level is such that a call to the error method will
log a message, otherwise false.

=method is_fatal

Returns true if the level is such that a call to the fatal method will
log a message, which is always the case.

