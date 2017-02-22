use strict;
use warnings;
use utf8;
use Test::More;

use Time::Piece::Plus;

my $sometime = "2017-02-21 18:09:11";
my $datetime_format = "%Y-%m-%d %H:%M:%S";
my $time = Time::Piece::Plus->strptime($sometime, $datetime_format);

subtest 'without delimiter' => sub {
    my $got = $time->mmddyyyy;
    is $got, '02212017';
};

subtest 'with delimiter' => sub {
    my $got = $time->mmddyyyy('/');
    is $got, '02/21/2017';
};

done_testing;

