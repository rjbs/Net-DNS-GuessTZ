use inc::Module::Install;
all_from('lib/Net/DNS/GuessTZ.pm');

requires('DateTime::TimeZone', '0.51'); # names_in_country
requires('IP::Country::Fast');
requires('List::Util');

extra_tests;
WriteAll;
