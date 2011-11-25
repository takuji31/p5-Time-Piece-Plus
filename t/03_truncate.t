use strict;
use Test::More;

use Time::Piece::Factory;

my $sometime = "2011-11-26 01:15:20";
my $datetime_format = "%Y-%m-%d %H:%M:%S";
my $time = Time::Piece->strptime($sometime, $datetime_format);

subtest "truncate to minute" => sub {
    my $truncated = $time->truncate(to => 'minute');
    is($truncated->second => 0, "seconds is truncated");
    is($truncated->strftime($datetime_format) => "2011-11-26 01:15:00", "correct truncated date");
    done_testing;
};

done_testing();
