use inc::Module::Install;
name 'Time-Piece-Plus';
all_from 'lib/Time/Piece/Plus.pm';

# requires '';
requires 'Data::Validator';
requires 'Mouse';
requires 'Time::Piece' => 1.12;
requires 'version';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More' => 0.98;
build_requires 'Test::LoadAllModules';
use_test_base;
auto_include;
WriteAll;
