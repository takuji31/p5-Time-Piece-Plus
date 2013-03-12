use strict;
use warnings;
use 5.10.0;
use Test::More;

use Time::Piece::Plus;

subtest "fix localtime or gmtime" => sub {
    my $now = localtime();
    my $localtime_from_gm = localtime(scalar gmtime());
    my $localtime_from_local = localtime(scalar localtime());
    is($now => $localtime_from_gm, 'Convert gmtime to localtime successful');
    is($now => $localtime_from_local, 'Convert localtime to localtime successful');
};

subtest "fix strptime from instance method" => sub {
    my $now = localtime();
    my $format = '%Y%m%d%H%M%S';
    my $str    = $now->strftime($format);
    my $parsed = localtime()->strptime($str, $format);
    is($now => $parsed , 'Parse successful');
    is($now->epoch => $parsed->epoch , 'epoch equals');
    is($now->strftime($format) => $parsed->strftime($format) , 'Same date and time');
};

subtest "fix strptime from class method" => sub {
    my $now = localtime();
    my $format = '%Y%m%d%H%M%S %z';
    my $str    = $now->strftime($format);
    my $parsed = localtime(Time::Piece::Plus->strptime($str, $format));
    is($now => $parsed , 'Parse successful');
    is($now->epoch => $parsed->epoch , 'epoch equals');
    is($now->strftime($format) => $parsed->strftime($format) , 'Same date and time');
};

done_testing();
