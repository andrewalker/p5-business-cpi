requires 'perl', 5.008;
requires 'Moo', 1.0;
requires 'Throwable';
requires 'Type::Tiny';
requires 'Type::EmailAddress';
requires 'Locale::Currency';
requires 'Locale::Country';
requires 'Email::Valid';
requires 'Class::Load', '0.20';
requires 'HTML::Element';
requires 'Scalar::Util';
requires 'List::Util';
requires 'DateTime';

on 'test' => sub {
    requires 'Test::Exception', '0.32';
};
