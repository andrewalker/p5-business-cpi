use warnings;
use strict;
use Test::More;
use Business::CPI::Util::EmptyLogger;

ok(my $log = Business::CPI::Util::EmptyLogger->new(), 'the empty logger builds');
isa_ok($log, 'Business::CPI::Util::EmptyLogger', '$log');
ok(!$log->is_debug, "it's not debug");

map {
    is($log->$_,  undef, "$_ doesn't do anything")
} qw/debug info warn error fatal/;

done_testing;
