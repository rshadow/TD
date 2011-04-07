use strict;
use warnings;
use utf8;

package Game::TD::Unit;
use base qw(Game::TD::View);
#use base qw(Exporter);
#our @EXPORT = qw();

use Carp;
use SDLx::Sprite::Animated;

use Game::TD::Config;

=head1 NAME

Game::TD::Model::Unit - Модуль

=head1 SYNOPSIS

  use Game::TD::Model::Unit;

=head1 DESCRIPTION

=cut

=head1 METHODS

=cut

sub new
{
    my ($class, %opts) = @_;

    croak 'Missing required param "app"'        unless defined $opts{app};

    croak 'Missing required param "type"'       unless defined $opts{type};
    croak 'Missing required param "x"'          unless defined $opts{x};
    croak 'Missing required param "y"'          unless defined $opts{y};
    croak 'Missing required param "direction"'  unless defined $opts{direction};
    croak 'Missing required param "span"'       unless defined $opts{span};
    croak 'Missing required param "path"'       unless defined $opts{path};

    my $self = bless \%opts, $class;

    # Get from config
    my %unit = %{ config->param('unit'=>$self->type) || {} };
    %unit = %{ config->param('unit'=>'unknown') } unless %unit;

    # Concat
    $self->{$_} = $unit{$_} for qw(speed health);

    # Load animation
    $self->sprite(unit => SDLx::Sprite::Animated->new(
        images          => $unit{animation}{right},
        type            => $unit{animation}{type} || 'circular',
        ticks_per_frame => $self->speed * $self->app->dt,
        x               => $self->x,
        y               => $self->y,
    ));
    # Randomize start frame
    $self->sprite('unit')->next
        for 0 .. rand scalar @{ $unit{animation}{right} };
    $self->sprite('unit')->start;

    $self->_init_editor if config->param('editor'=>'enable');

    return $self;
}

sub type    {return shift()->{type}     }
sub path    {return shift()->{path}     }
sub speed   {return shift()->{speed}    }
sub health  {return shift()->{health}   }

sub conf
{
    my $self = shift;
    return $self->{conf} // 'unit';
}

sub direction
{
    my ($self, $direction) = @_;
    $self->{direction} = $direction if defined $direction;
    return $self->{direction};
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

sub move
{
    my ($self, $dt) = @_;

    # Do not move die unit
    return unless $self->health;
    return unless $self->speed;
    return unless $self->direction;

    # Set dt
    $dt //= $self->app->dt;

    # Move unit
    if($self->direction eq 'left')
    {
        $self->x( $self->x - $self->speed * $dt);
    }
    elsif($self->direction eq 'right')
    {
        $self->x( $self->x + $self->speed * $dt);
    }
    elsif($self->direction eq 'up')
    {
        $self->y( $self->y - $self->speed * $dt);
    }
    elsif($self->direction eq 'down')
    {
        $self->y( $self->y + $self->speed * $dt);
    }
    else
    {
        confess 'Unknown direction';
    }
}

sub span
{
    my ($self, $span) = @_;
    $self->{span} = $span if defined $span;
    return $self->{span};
}

sub draw
{
    my $self = shift;

    $self->sprite('unit')->x( $self->x );
    $self->sprite('unit')->y( $self->y );
    $self->sprite('unit')->draw( $self->app );

    $self->font('editor_tail')->write_xy(
        $self->app,
        $self->x,
        $self->y,
        sprintf('%s %s:%s', $self->direction, $self->x, $self->y),
    ) if config->param('editor'=>'enable');
}

1;