use inc::Module::Install;
name 'Time-Piece-Factory';
all_from 'lib/Time/Piece/Factory.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
build_requires 'Test::LoadAllModules';
use_test_base;
auto_include;
WriteAll;
