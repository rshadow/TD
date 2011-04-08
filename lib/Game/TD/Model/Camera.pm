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
    $opts{left}     //= config->param('game'=>'map'=>'left');
    $opts{top}      //= config->param('game'=>'map'=>'top');
    $opts{move}     //= {};

    my $self = bless \%opts, $class;

    $self->{rect} = SDL::Rect->new($self->left, $self->top, $self->w, $self->h);

    return $self;
}

sub map         { return shift()->{map} }
sub rect        { return shift()->{rect} }
sub speed       { return shift()->{speed} }
sub width       { return CAMERA_WIDTH }
sub height      { return CAMERA_HEIGHT }
sub left        { return shift()->{left} }
sub top         { return shift()->{top} }

sub clip
{
    my $self = shift;
    return SDL::Rect->new($self->x, $self->y, $self->w, $self->h);
}

sub x
{
    my ($self, $x) = @_;
    $self->{x} = $x if defined $x;
    return $self->{x};
}

sub y
{
    my ($self, $y) = @_;
    $self->{y} = $y if defined $y;
    return $self->{y};
}


sub w
{
    my $self = shift;
    return $self->width * $self->map->tail_width;
}

sub h
{
    my $self = shift;
    return $self->height * $self->map->tail_height;
}

sub is_move
{
    my ($self, $direction) = @_;
    return exists $self->{move}{$direction};
}

sub move
{
    my ($self, $direction) = @_;
    $self->{move}{$direction} = 1 if defined $direction;
    return $self->{move}{$direction};
}

sub stop
{
    my ($self, $direction) = @_;
    delete $self->{move}{$direction};
}

sub update
{
    my ($self) = @_;

    if($self->is_move('up'))
    {
        $self->y( $self->y - $self->speed );
        $self->y( 0 ) if $self->y <= 0;
    }

    if($self->is_move('down'))
    {
        $self->y( $self->y + $self->speed );
        my $bottom = $self->map->tail_map_height - $self->h;
        $self->y( $bottom ) if $self->y >= $bottom;
    }

    if($self->is_move('left'))
    {
        $self->x( $self->x - $self->speed );
        $self->x( 0 ) if $self->x <= 0;
    }

    if($self->is_move('right'))
    {
        $self->x( $self->x + $self->speed );
        my $right = $self->map->tail_map_width - $self->w;
        $self->x( $right ) if $self->x >= $right;
    }
}

1;