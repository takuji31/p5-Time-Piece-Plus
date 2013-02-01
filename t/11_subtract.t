use strict;
use warnings;
use utf8;
use Test::More;

use Time::Piece::Plus;

my $sometime = "2011-11-26 01:15:20";
my $datetime_format = "%Y-%m-%d %H:%M:%S";
my $time = Time::Piece::Plus->strptime($sometime, $datetime_format);

subtest original => sub {
    my $subtracted = $time->subtract(10);
    is($subtracted->strftime($datetime_format) => "2011-11-26 01:15:10", "correctly subtracted");
};

subtest subtract_days => sub {
    my $subtracted = $time->subtract(days => 1);
    is($subtracted->strftime($datetime_format) => "2011-11-25 01:15:20", "correctly subtracted");
};

subtest subtract_month => sub {
    my $subtracted = $time->subtract(months => 1);
    is($subtracted->strftime($datetime_format) => "2011-10-26 01:15:20", "correctly subtracted");
};

subtest subtract_year => sub {
    my $subtracted = $time->subtract(years => 1);
    is($subtracted->strftime($datetime_format) => "2010-11-26 01:15:20", "correctly subtracted");
};

subtest subtract_all => sub {
    my $subtracted = $time->subtract(years => 1, months => 1, days => 1, hours => 1, seconds => 1, minutes => 1);
    is($subtracted->strftime($datetime_format) => "2010-10-25 00:14:19", "correctly subtracted");
};

done_testing;
