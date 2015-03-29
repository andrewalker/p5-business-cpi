use warnings;
use strict;
use Test::More;
use Business::CPI::Util::SimpleLogger;
use Business::CPI;

my $have_test_trap;
our $trap;
BEGIN {
    eval {
        require Test::Trap;
        Test::Trap->import (qw/trap $trap :flow :stderr(systemsafe)/);
        $have_test_trap = 1;
    };
}

ok(my $log = Business::CPI::Util::SimpleLogger->new(), 'the simple logger builds');
isa_ok($log, 'Business::CPI::Util::SimpleLogger', '$log');

map {
    ok(!$log->$_, "$_ returns false")
} qw/is_debug is_info/;
map {
    ok($log->$_, "$_ returns true")
} qw/is_warn is_error is_fatal/;

my @levels = qw/debug info warn error fatal/;
for my $i (0..$#levels) {
    $log->set_level($levels[$i]);
    for my $j (0..$#levels) {
        my $checksub = "is_$levels[$j]";
        if ($j >= $i) {
            ok($log->$checksub, "At $levels[$i], $checksub is true");
        } else {
            ok(!$log->$checksub, "At $levels[$i], $checksub is false");
        }

    }
}

# Use Test::Trap where available to test wanrings and terminating
# functions.
SKIP: {
    skip "Test::Trap not available", (($#levels+1)**2) unless $have_test_trap;
    my @r = ();
    for my $i (0..$#levels) {
        $log->set_level($levels[$i]);
        for my $j (0..$#levels) {
            my $logsub = "$levels[$j]"; 
            my $trapmess = "Trap Test $i $j\n"; 
            @r = trap { $log->$logsub($trapmess) };
            my $err = $logsub eq 'fatal' ? $trap->die : $trap->stderr;
            if ($j >= $i) {
                is($err, (uc ($logsub) . ": $trapmess"),
                    "At $levels[$i], $logsub logs message");
            } else {
                is($err, '',
                    "At $levels[$i], $logsub is no-op");
            }
        }
    }
    
    # Test the logging of warnings in the modules
    my $cpi = Business::CPI->new(gateway => 'Test');
    @r = trap { $cpi->notify() };
    like($trap->die, qr/FATAL: Not implemented/,
        'Businss::CPI::Gateway::Base->notify dies');
}

done_testing;
