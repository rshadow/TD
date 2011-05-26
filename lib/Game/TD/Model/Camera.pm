package Game::TD::Model::Camera;
#use base qw(Exporter);
#our @EXPORT = qw();

use warnings;
use strict;
use utf8;

use Carp;
use SDL::Rect;

use Game::TD::Config;

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
    $opts{w}        //= config->param('common'=>'camera'=>'width');
    $opts{h}        //= config->param('common'=>'camera'=>'height');
    $opts{left}     //= config->param('common'=>'camera'=>'left');
    $opts{top}      //= config->param('common'=>'camera'=>'top');
    $opts{move}     //= {};

    my $self = bless \%opts, $class;

    $self->{rect} = SDL::Rect->new($self->left, $self->top, $self->w, $self->h);

    return $self;
}

sub map         { return shift()->{map} }
sub rect        { return shift()->{rect} }
sub speed       { return shift()->{speed} }
sub left        { return shift()->{left} }
sub top         { return shift()->{top} }
sub w           { return shift()->{w} }
sub h           { return shift()->{h} }

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


#sub w
#{
#    my $self = shift;
#    return $self->width * $self->map->tile_width;
#}
#
#sub h
#{
#    my $self = shift;
#    return $self->height * $self->map->tile_height;
#}

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
        my $bottom = $self->map->tile_map_height - $self->h;
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
        my $right = $self->map->tile_map_width - $self->w;
        $self->x( $right ) if $self->x >= $right;
    }
}

=head2 is_over $x, $y

Check if $x and $y coordinates within camera rect

=cut

sub is_over
{
    my ($self, $x, $y) = @_;

    return 1 if
        $x >= $self->rect->x                  &&
        $x <  $self->rect->x + $self->rect->w &&
        $y >= $self->rect->y                  &&
        $y <  $self->rect->y + $self->rect->h;

    return 0;
}

=head2 xy2map $x, $y

Get logical x and y on map for coordinates $x,$y. Function make correction for
camera movements.

=cut

sub xy2map
{
    my ($self, $x, $y) = @_;

    my $map_x =  int( ($self->x + $x) / $self->map->tile_width  );
    my $map_y =  int( ($self->y + $y) / $self->map->tile_height );

    return ($map_x, $map_y);
}

1;