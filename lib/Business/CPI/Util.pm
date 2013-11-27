package Business::CPI::Util;
# ABSTRACT: Utilities for Business::CPI
use warnings;
use strict;
use utf8;
use Class::Load ();

# VERSION

sub load_class {
    my ($driver_name, $class_name) = @_;
    return Class::Load::load_first_existing_class(
        "Business::CPI::${driver_name}::${class_name}",
        "Business::CPI::Base::${class_name}"
    );
}

1;

=method load_class

Used to load a class, either a custom class of the gateway, or the default one
in Business::CPI core.
