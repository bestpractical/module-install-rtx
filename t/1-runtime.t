#!/usr/bin/perl

use Test::More;

require Module::Install::RTx::Runtime;

is ( Module::Install::RTx::Runtime::_convert_version('1'), '1',
    'is 1 converted to 1');
is ( Module::Install::RTx::Runtime::_convert_version('1.0'), '1.0',
    'is 1.0 converted to 1.0');
is ( Module::Install::RTx::Runtime::_convert_version('0.1'), '0.1',
    'is 0.1 converted to 0.1');
is ( Module::Install::RTx::Runtime::_convert_version('0.0.1'), '0.001',
    'is 0.0.1 converted to 0.001');
is ( Module::Install::RTx::Runtime::_convert_version('11'), '11',
    'is 11 converted to 11');
is ( Module::Install::RTx::Runtime::_convert_version('11.0'), '11.0',
    'is 11.0 converted to 11.0');
is ( Module::Install::RTx::Runtime::_convert_version('4.4.18'), '4.4018',
    'is 4.4.18 converted to 4.4018');
is ( Module::Install::RTx::Runtime::_convert_version('4.40.18'), '4.40018',
    'is 4.40.18 converted to 4.40018');
is ( Module::Install::RTx::Runtime::_convert_version('440.18'), '440.18',
    'is 440.18 converted to 440.18');
is ( Module::Install::RTx::Runtime::_convert_version('4.4.1.8'), '4.40108',
    'is 4.4.1.8 converted to 4.40108');

is ( Module::Install::RTx::Runtime::_equal('1', '1'), 1,
    '1 is equal to 1');
is ( Module::Install::RTx::Runtime::_equal('0.1', '0.1'), 1,
    '0.1 is equal to 0.1');
is ( Module::Install::RTx::Runtime::_equal('11', '1.1'), 0,
    '11 is not equal to 1.1');
is ( Module::Install::RTx::Runtime::_equal('1.1', '11'), 0,
    '1.1 is not equal to 11');
is ( Module::Install::RTx::Runtime::_equal('1.1', '1.1'), 1,
    '1.1 is equal to 1.1');
is ( Module::Install::RTx::Runtime::_equal('1.1.1', '1.1.1'), 1,
    '1.1.1 is equal to 1.1.1');
is ( Module::Install::RTx::Runtime::_equal('1.11.1', '1.11.1'), 1,
    '1.11.1 is equal to 1.11.1');
is ( Module::Install::RTx::Runtime::_equal('1.1.1', '1.11'), 0,
    '1.1.1 is not equal to 1.11');
is ( Module::Install::RTx::Runtime::_equal('1.11.1', '1.111'), 0,
    '1.11.1 is not equal to 1.111');
is ( Module::Install::RTx::Runtime::_equal('1.11.1', '1111'), 0,
    '1.11.1 is not equal to 1111');

is ( Module::Install::RTx::Runtime::_greater_than('2', '>1'), 1,
    '2 is greater than 1' );
is ( Module::Install::RTx::Runtime::_greater_than('1.1', '>1.1'), 0,
    '1.1 is not greater than 1.1' );
is ( Module::Install::RTx::Runtime::_greater_than('1.1', '>1'), 1,
    '1.1 is greater than 1' );
is ( Module::Install::RTx::Runtime::_greater_than('1.1', '>2'), 0,
    '1.1 is not greater than 2' );
is ( Module::Install::RTx::Runtime::_greater_than('1.1', '>11'), 0,
    '1.1 is not greater than 11' );
is ( Module::Install::RTx::Runtime::_greater_than('1.11', '>11.1'), 0,
    '1.11 is not greater than 11.1' );
is ( Module::Install::RTx::Runtime::_greater_than('111', '>11.1'), 1,
    '111 is greater than 11.1' );

is ( Module::Install::RTx::Runtime::_less_than('2', '<1'), 0,
    '2 is not less than 1' );
is ( Module::Install::RTx::Runtime::_less_than('1.1', '<1.1'), 0,
    '1.1 is not less than 1.1' );
is ( Module::Install::RTx::Runtime::_less_than('1.1', '<1'), 0,
    '1.1 is not less than 1' );
is ( Module::Install::RTx::Runtime::_less_than('1.1', '<2'), 1,
    '1.1 is less than 2' );
is ( Module::Install::RTx::Runtime::_less_than('1.1', '<11'), 1,
    '1.1 is less than 11' );
is ( Module::Install::RTx::Runtime::_less_than('1.11', '<11.1'), 1,
    '1.11 is less than 11.1' );
is ( Module::Install::RTx::Runtime::_less_than('111', '<11.1'), 0,
    '111 is not less than 11.1' );

is ( Module::Install::RTx::Runtime::_in_range('1.1', '1-1.5'), 1,
    '1.1 is in range 1 and 1.5' );
is ( Module::Install::RTx::Runtime::_in_range('0.1', '1-1.5'), 0,
    '0.1 is not in range 1 and 1.5' );
is ( Module::Install::RTx::Runtime::_in_range('2.1', '2-3'), 1,
    '2.1 is in range 2 and 3' );
is ( Module::Install::RTx::Runtime::_in_range('2', '2-3'), 1,
    '2 is between 2 and 3' );
is ( Module::Install::RTx::Runtime::_in_range('2.0', '2-3'), 1,
    '2.0 is in range 2 and 3' );
is ( Module::Install::RTx::Runtime::_in_range('2', '2-2'), 1,
    '2 is in range 2 and 2' );

done_testing($number_of_tests);

1;
