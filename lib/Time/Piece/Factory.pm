package Time::Piece::Factory;
use strict;
use warnings;
use 5.10.0;

our $VERSION = '0.01';

use Time::Piece ();

sub import {
    my $class  = shift;
    my $caller = caller;

    for my $function (qw(localtime gmtime))  {
        no strict 'refs';
        *{"$caller\::$function"} = \&{"Time::Piece::$function"};
    }

}

package  Time::Piece;
use strict;
use warnings;

use Time::Seconds;
use Data::Validator;

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

    $self->localtime(($self - ONE_DAY)->reparse(format_string => '%Y%m%d'));
}

sub tomorrow {
    my ($self, ) = @_;

    $self = $self->get_object;

    $self->localtime(($self + ONE_DAY)->reparse(format_string => '%Y%m%d'));
}

my %TRUNCATE_FORMAT = (
    minute  => '%Y%m%d%H%M00',
    hour    => '%Y%m%d%H0000',
    day     => '%Y%m%d000000',
    month   => '%Y%m01000000',
    year    => '%Y0101000000',
);

use Mouse::Util::TypeConstraints;

enum 'Time::Piece::Factory::ColumTypes' => keys %TRUNCATE_FORMAT;

no Mouse::Util::TypeConstraints;

sub truncate {
    state $validator = Data::Validator->new(
        to => {isa => 'Time::Piece::Factory::ColumTypes'},
    )->with(qw(Method));
    my ($self, $args) = $validator->validate(@_);
    my $format = $TRUNCATE_FORMAT{$args->{to}};
    $self = $self->get_object;
    return $self->reparse(format_string => $format);
}

1;
__END__

=encoding utf-8

=head1 NAME

Time::Piece::Factory - Factory module for Time::Piece

=head1 SYNOPSIS

  use Time::Piece::Factory;

  #As class method
  my $time = Time::Piece->yesterday;
  my $tomorrow = Time::Piece->tomorrow;

  #As instance method
  my $time = Time::Piece->yesterday;
  my $two_days_ago = $time->yesterday;
  my $today = $time->tomorrow;

  #returns hour truncated object
  $time->truncate(to => 'day');

=head1 DESCRIPTION

Time::Piece::Factory is Factory module for Time::Piece

Add some useful methods to Time::Piece

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

=head1 AUTHOR

Nishibayashi Takuji E<lt>takuji {at} senchan.jpE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
