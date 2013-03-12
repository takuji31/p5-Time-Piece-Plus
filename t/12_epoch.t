use strict;
use warnings;
use utf8;
use Test::More;
use Time::Piece::Plus ();
use Time::Piece ();

plan skip_all => 'Time::Piece is old' if Time::Piece::Plus::need_patch();

is(Time::Piece::Plus->localtime->epoch, Time::Piece::Plus->gmtime->epoch);
is(Time::Piece->localtime->epoch, Time::Piece::Plus->localtime->epoch);

done_testing;
