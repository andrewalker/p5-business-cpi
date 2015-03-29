package Business::CPI::Role::Gateway::Base;
# ABSTRACT: Basic role for all gateway drivers
use Moo::Role;
use utf8;
use Business::CPI::Util;
use Business::CPI::Util::SimpleLogger;

# VERSION

has driver_name => (
    is      => 'ro',
    default => sub { ( split /::/, ref $_[0] )[-1] },
);

has log => (
    is => 'ro',
    default => sub { Business::CPI::Util::SimpleLogger->new },
);

has item_class => (
    is => 'lazy',
    default => sub { shift->_load_class('Item') },
);

has cart_class => (
    is => 'lazy',
    default => sub { shift->_load_class('Cart') },
);

has buyer_class => (
    is => 'lazy',
    default => sub { shift->_load_class('Buyer') },
);

has receiver_class => (
    is => 'lazy',
    default => sub { shift->_load_class('Receiver') },
);

has account_class => (
    is => 'lazy',
    default => sub { shift->_load_class('Account') },
);

has account_address_class => (
    is => 'lazy',
    default => sub { shift->_load_class('Account::Address') },
);

has account_business_class => (
    is => 'lazy',
    default => sub { shift->_load_class('Account::Business') },
);

sub _load_class {
    Business::CPI::Util::load_class(shift->driver_name, @_);
}

1;

=attr driver_name

The name of the driver for this gateway. This is built automatically, but can
be customized.

Example: for C<Business::CPI::Gateway::TestGateway>, the driver name will be
C<TestGateway>.

=attr log

Provide a logger to the gateway. It's the user's responsibility to configure
the logger. By default, nothing is logged. You could set this to a
L<Log::Log4perl> object, for instance, to get full logging.

=attr item_class

The class for the items (products) being purchased. Defaults to
Business::CPI::${driver_name}::Item if it exists, or
L<Business::CPI::Base::Item> otherwise.

=attr cart_class

The class for the shopping cart (the complete order). Defaults to
Business::CPI::${driver_name}::Cart if it exists, or
L<Business::CPI::Base::Cart> otherwise.

=attr buyer_class

The class for the buyer (the sender). Defaults to
Business::CPI::${driver_name}::Buyer if it exists, or
L<Business::CPI::Base::Buyer> otherwise.

=attr receiver_class

The class for the receivers. Defaults to Business::CPI::${driver_name}::Receiver
if it exists, or L<Business::CPI::Base::Receiver> otherwise.

=attr account_class

The class for the accounts. Defaults to Business::CPI::${driver_name}::Account
if it exists, or L<Business::CPI::Base::Account> otherwise.

=attr account_address_class

The class for the addresses for the accounts. Defaults to
Business::CPI::${driver_name}::Account::Address if it exists, or
L<Business::CPI::Base::Account::Address> otherwise.

=attr account_business_class

The class for the business information of accounts. Defaults to
Business::CPI::${driver_name}::Account::Business if it exists, or
L<Business::CPI::Base::Account::Business> otherwise.
