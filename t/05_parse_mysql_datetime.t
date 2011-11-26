use strict;
use warnings;
use 5.10.0;
use Test::More;

use Time::Piece::Factory;

my $sometime = "2011-11-26 23:01:10";
my $datetime_format = "%Y-%m-%d %H:%M:%S";
my $time = Time::Piece::Factory->strptime($sometime, $datetime_format);
my $localtime = localtime->strptime($sometime, $datetime_format);

subtest "as gmtime" => sub {
    my $parsed = Time::Piece::Factory->parse_mysql_datetime(str => $sometime, as_localtime => 0);
    isa_ok($parsed => 'Time::Piece::Factory', "returns Time::Piece::Factory instance");
    is($parsed->epoch => $time->epoch, "parsed correctly");
    is($parsed->strftime($datetime_format) => $sometime, "correct parsed datetime");
    done_testing;
};

subtest "as localtime" => sub {
    my $parsed = Time::Piece::Factory->parse_mysql_datetime(str => $sometime, as_localtime => 1);
    isa_ok($parsed => 'Time::Piece::Factory', "returns Time::Piece::Factory instance");
    is($parsed->epoch => $localtime->epoch, "parsed correctly");
    is($parsed->strftime($datetime_format) => $sometime, "correct parsed datetime");
    done_testing;
};

subtest "epoch minus datetime" => sub {
    my $somoday = "1969-12-31 23:59:59";
    my $parsed = Time::Piece::Factory->parse_mysql_datetime(str => $somoday, as_localtime => 0);
    isa_ok($parsed => 'Time::Piece::Factory', "parsed correctly");
    ok(($parsed->epoch == -1), "correct parsed datetime");
    done_testing;
};

done_testing();
