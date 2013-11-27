package Business::CPI::Util;
use warnings;
use strict;
use utf8;
use Class::Load ();

sub load_class {
    my ($driver_name, $class_name) = @_;
    return Class::Load::load_first_existing_class(
        "Business::CPI::${driver_name}::${class_name}",
        "Business::CPI::Base::${class_name}"
    );
}

1;
