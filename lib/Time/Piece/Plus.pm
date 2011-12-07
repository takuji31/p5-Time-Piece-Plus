package Time::Piece::Plus;
use strict;
use warnings;
use 5.010;

our $VERSION = '0.01';

BEGIN {
    require Time::Piece;
    require version;
    unshift @Time::Piece::Plus::ISA, 'Time::Piece';
    # Object creation bug fix patch for Time::Piece < 1.16
    my $NEED_PATCH = version::qv($Time::Piece::VERSION) < version::qv("1.16") ? 1 : 0;
    sub need_patch() {$NEED_PATCH} ## no critic
}

sub import {
    my $class  = shift;
    my $caller = caller;
    for my $method (qw(localtime gmtime)) {
        my $code = sub {$class->$method(@_)};
        {
            no strict 'refs';
            *{"$caller\::$method"} = $code; ## no critic
        }
    }
}

use Time::Seconds;
use Data::Validator;

sub localtime {
    my $self = shift;
    return $self->create_object(1, @_);
}

sub gmtime {
    my $self = shift;
    return $self->create_object(0, @_);
}

sub create_object {
    my $self = shift;
    my $is_local = shift;

    my @origin = $is_local ? Time::Piece::localtime(@_) : Time::Piece::gmtime(@_);
    #If array context, returns time array.
    return @origin if wantarray;

    my $is_instance = ref $self ? 1 : 0;
    my $class       = $is_instance ? ref $self : $self;
    if(need_patch() && (@origin > 11)) {
        @origin = (@origin[0..9], $origin[-1]);
    }
    bless \@origin, $class;
}

sub get_object {
    my ($self, ) = @_;

    $self = $self->localtime unless ref $self;
    return $self;
}

sub reparse {
    state $validator = Data::Validator->new(
        format_string => {isa => 'Str'},
        parse_string  => {isa => 'Str', default => sub{$_[2]->{format_string}}},
    )->with(qw(Method));
    my ($self, $args) = $validator->validate(@_);

    $self->strptime($self->strftime($args->{format_string}), $args->{parse_string});
}

sub yesterday {
    my ($self, ) = @_;

    $self = $self->get_object;

    ($self - ONE_DAY)->truncate(to => 'day');
}

sub tomorrow {
    my ($self, ) = @_;

    $self = $self->get_object;

    ($self + ONE_DAY)->truncate(to => 'day');
}

my %TRUNCATE_FORMAT = (
    minute  => '%Y%m%d%H%M00',
    hour    => '%Y%m%d%H0000',
    day     => '%Y%m%d000000',
    month   => '%Y%m01000000',
    year    => '%Y0101000000',
);

use Mouse::Util::TypeConstraints;

enum 'Time::Piece::Plus::ColumTypes' => keys %TRUNCATE_FORMAT;

no Mouse::Util::TypeConstraints;

sub truncate {
    state $validator = Data::Validator->new(
        to => {isa => 'Time::Piece::Plus::ColumTypes'},
    )->with(qw(Method));
    my ($self, $args) = $validator->validate(@_);
    my $format = $TRUNCATE_FORMAT{$args->{to}};
    $self = $self->get_object;
    return $self->reparse(format_string => $format);
}

sub parse_mysql_date {
    state $validator = Data::Validator->new(
        str => {isa => 'Str'},
        as_localtime => {isa => 'Bool', default => 1},
    )->with(qw(Method));
    my ($class, $args) = $validator->validate(@_);

    return unless $args->{str} && $args->{str} ne "0000-00-00";

    my $self = $args->{as_localtime} ? $class->localtime() : $class->gmtime();
    my $parsed = $self->strptime($args->{str}, '%Y-%m-%d');

    return $parsed;
}

sub parse_mysql_datetime {
    state $validator = Data::Validator->new(
        str => {isa => 'Str'},
        as_localtime => {isa => 'Bool', default => 1},
    )->with(qw(Method));
    my ($class, $args) = $validator->validate(@_);

    return unless $args->{str} && $args->{str} ne "0000-00-00 00:00:00";

    my $self = $args->{as_localtime} ? $class->localtime() : $class->gmtime();
    my $parsed = $self->strptime($args->{str}, '%Y-%m-%d %H:%M:%S');

    return $parsed;
}

sub mysql_date {
    my ($self, ) = @_;
    $self = $self->get_object;
    return $self->strftime("%Y-%m-%d");
}
sub mysql_datetime {
    my ($self, ) = @_;
    $self = $self->get_object;
    return $self->strftime("%Y-%m-%d %H:%M:%S");
}

1;
__END__

=encoding utf-8

=head1 NAME

Time::Piece::Plus - Subclass of Time::Piece with some useful method

=head1 SYNOPSIS

  use Time::Piece::Plus;

  #As class method
  my $time = Time::Piece::Plus->yesterday;
  my $tomorrow = Time::Piece::Plus->tomorrow;

  #As instance method
  my $time = Time::Piece::Plus->yesterday;
  my $two_days_ago = $time->yesterday;
  my $today = $time->tomorrow;

  #returns hour truncated object
  $time->truncate(to => 'day');

  #parse MySQL DATE
  my $gm_date    = Time::Piece::Plus->parse_mysql_date(str => "2011-11-26", as_localtime => 0);
  my $local_date = Time::Piece::Plus->parse_mysql_date(str => "2011-11-26", as_localtime => 1);
  #default is localtime
  my $local_date = Time::Piece::Plus->parse_mysql_date(str => "2011-11-26");

  #parse MySQL DATETIME
  my $gm_datetime    = Time::Piece::Plus->parse_mysql_datetime(str => "2011-11-26 23:28:50", as_localtime => 0);
  my $local_datetime = Time::Piece::Plus->parse_mysql_datetime(str => "2011-11-26 23:28:50", as_localtime => 1);
  #default is localtime
  my $datetime       = Time::Piece::Plus->parse_mysql_datetime(str => "2011-11-26 23:28:50");


=head1 DESCRIPTION

Time::Piece::Plus is subclass of Time::Piece with some useful method.

=head1 METHODS

=head2 yesterday

If called as a class method returns yesterday.
Also, if called as an instance method returns the previous day.
And time is cut.

=head2 tomorrow

If called as a class method returns tomorrow.
Also, if called as an instance method returns the next day.
And time is cut.

=head2 truncate

Cut the smaller units than those specified.
For example, "day" if you will cut the time you specify.
2011-11-26 02:13:22 -> 2011-11-26 00:00:00
Each unit is a minimum cut.

=head2 parse_mysql_date

Parse MySQL DATE string like "YYYY-mm-dd".
as_localtime is optional, default is 1.

=head2 parse_mysql_datetime

Parse MySQL DATETIME string like "YYYY-mm-dd HH:MM:SS".
as_localtime is optional, default is 1.

=head2 mysql_date

Format MySQL DATE string like "YYYY-mm-dd".
If you call a class method and returns the format today.
Also, if called as an instance method returns the date and format of the instance.

=head2 mysql_datetime

Format MySQL DATE string like "YYYY-mm-dd HH:MM:SS".
If you call a class method and returns the format now.
Also, if called as an instance method returns the date and format of the instance.

=head1 AUTHOR

Nishibayashi Takuji E<lt>takuji {at} senchan.jpE<gt>

=head1 SEE ALSO

L<Time::Piece>,L<Time::Piece::MySQL>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
