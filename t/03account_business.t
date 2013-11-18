#!/usr/bin/env perl
use warnings;
use strict;
use utf8;
use Business::CPI::Gateway::Test;
use Business::CPI::Account::Business;
use Test::More;
use Test::Exception;

my @attrs = qw/corporate_name trading_name phone address/;
my $class = 'Business::CPI::Account::Business';

# Test class meta
{
    ok($class->can('new'), 'Class can be instantiated');

    for my $attr (@attrs) {
        ok($class->can($attr), qq{class has attribute $attr});
    }
}

# Test building the object
{
    my $obj;
    my %data = (
        _gateway       => Business::CPI::Gateway::Test->new,
        corporate_name => 'Aware Ltda.',
        trading_name   => 'Aware',
        phone          => '11 11110000',
        address        => {
            zip_code   => '12345-000',
            street     => 'Alameda Santos',
            number     => '321',
            complement => '3º andar',
            district   => 'Bairro Y',
            city       => 'São Paulo',
            state      => 'SP',
            country    => 'br',
        },
    );

    lives_ok {
        $obj = $class->new(%data);
    } 'Object is built ok';

    isa_ok($obj, $class);

    for (keys %data) {
        is($obj->$_, $data{$_}, $_ . ' is set ok') if $_ ne 'address';
    }

    isa_ok($obj->address, 'Business::CPI::Account::Address');
    is($obj->address->number, '321', 'address seems to be the one we provided');
}

done_testing();
