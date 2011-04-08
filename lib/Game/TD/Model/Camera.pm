package Game::TD::Model::Camera;
#use base qw(Exporter);
#our @EXPORT = qw();

use warnings;
use strict;
use utf8;

use Carp;
use SDL::Rect;

use Game::TD::Config;

use constant CAMERA_WIDTH   => 15;
use constant CAMERA_HEIGHT  => 15;

=head1 NAME

Game::TD::Model::Camera - Модуль

=head1 SYNOPSIS

  use Game::TD::Model::Camera;

=head1 DESCRIPTION

=cut

#use CGI::Carp qw(fatalsToBrowser);
#use CGI qw(:standard);

=head1 METHODS

=cut

sub new
{
    my ($class, %opts) = @_;

    croak 'Missing required param "map"'   unless defined $opts{map};

    $opts{x}        //= 0;
    $opts{y}        //= 0;
    $opts{speed}    //= config->param('common'=>'camera'=>'speed');

    my $self = bless \%opts, $class;

    return $self;
}

sub x           { return shift()->{x} }
sub y           { return shift()->{y} }
sub map         { return shift()->{map} }
sub speed       { return shift()->{speed} }
sub width       { return CAMERA_WIDTH }
sub height      { return CAMERA_HEIGHT }

sub rect
{
    my $self = shift;
    return SDL::Rect->new($self->x, $self->y, $self->w, $self->h);
}

sub w
{
    my $self = shift;
    return $self->width * $self->map->tail_map_width;
}

sub h
{
    my $self = shift;
    return $self->height * $self->map->tail_map_height;
}

sub update
{
    my ($self, $x, $y) = @_;

}

1;