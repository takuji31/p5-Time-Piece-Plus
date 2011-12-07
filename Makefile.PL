use inc::Module::Install;
name 'Time-Piece-Plus';
all_from 'lib/Time/Piece/Plus.pm';

# requires '';
requires 'Time::Piece' => 1.12;
requires 'Data::Validator';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
build_requires 'Test::LoadAllModules';
use_test_base;
auto_include;
WriteAll;
