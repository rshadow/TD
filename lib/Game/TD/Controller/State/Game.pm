use strict;
use warnings;
use utf8;

package Game::TD::Controller::State::Game;
use base qw(Game::TD::Controller);

use Carp;
use SDL::Event;

use Game::TD::Config;
use Game::TD::Model::State::Game;
use Game::TD::View::State::Game;
use Game::TD::Button;
use Game::TD::Unit;

=head1 NAME

Game::TD::Controller::State::Game - Модуль

=head1 SYNOPSIS

  use Game::TD::Controller::State::Game;

=head1 DESCRIPTION

=cut

=head1 METHODS

=cut

sub new
{
    my ($class, %opts) = @_;

    die 'Missing required param "app"'      unless defined $opts{app};
    die 'Missing required param "player"'   unless defined $opts{player};
    die 'Missing required param "level"'    unless defined $opts{level};

    my $self = $class->SUPER::new(%opts);

    $self->model( Game::TD::Model::State::Game->new(
        level       => $opts{level},
        player      => $self->player,
        dt          => $self->app->dt,
    ));

    $self->view( Game::TD::View::State::Game->new(
        app     => $self->app,
        model   => $self->model
    ));

    $self->button('menu' => Game::TD::Button->new(
        name    => 'menu',
        app     => $self->app,
        conf    => $self->conf,
    ));

#    my @path = keys %{ $self->model->level->wave };
#
#    for my $path ( @path )
#    {
#        my $tail = $self->model->level->map->start($path);
#
#        for my $rec ( @{ $self->model->level->wave->{$path} } )
#        {
#            $self->unit( Game::TD::Unit->new(
#                app         => $self->app,
#                type        => $rec->{unit},
#                x           => $tail->x * $self->map->tail_width,
#                y           => $tail->y * $self->map->tail_height,
#                direction   => 'right',
#                span        => $rec->{span},
#            ));
#        }
#    }
#
    $self->unit('1' => Game::TD::Unit->new(
        app     => $self->app,
        x       => 500,
        y       => 500,
        type    => 'ambusher',
        direction   => 'right',
        span        => 0,
    ));

    return $self;
}

sub update
{
    my ($self) = @_;

    my %result;

    my $process = $self->model->update;
    $result{state} = 'score' unless $process;

    return \%result;
}

sub event
{
    my ($self, $event) = @_;

    my %result;
    my $type = $event->type;

    # Just send event to buttons
    if($type == SDL_MOUSEMOTION or $type == SDL_MOUSEBUTTONDOWN)
    {
        $self->button('menu')->event( $event );
#        for my $index (0 .. $#{$self->model->levels})
#        {
#            my $name = 'level' . $index;
#            $self->button($name)->event( $event );
#        }
    }
    # Respond to button up state
    elsif($type == SDL_MOUSEBUTTONUP)
    {
        my $state = $self->button('menu')->event( $event );
        if( $state eq 'up' )
        {
            $result{state} = 'menu';
        }
#        else
#        {
#            for my $index (0 .. $#{$self->model->levels})
#            {
#                my $name = 'level' . $index;
#                my $state = $self->button($name)->event( $event );
#                if( $state eq 'up' )
#                {
#                    $result{state} = 'game';
#                    $result{level} = $index;
#                }
#            }
#        }
    }

    return \%result;
}

sub draw
{
    my $self = shift;

    $self->view->draw;

    $self->button('menu')->draw;

    $self->unit('1')->move;
    $self->unit('1')->draw;

    my ($mx, $my) = $self->map_xy( $self->unit('1') );
    printf "%s : %s \n", $mx, $my;

#    for my $index (0 .. $#{$self->model->levels})
#    {
#        my $name = 'level' . $index;
#        $self->button($name)->draw;
#    }

    return 1;
}



sub player
{
    return shift()->{player};
}

=head2 unit $name, $value

Common storage for units. Get $name for unit and typically
Game::TD::Unit object in $value.

=cut

sub unit
{
    my ($self, $name, $value) = @_;

    croak 'Name required'           unless defined $name;
    $self->{unit}{$name} = $value   if defined $value;
    return $self->{unit}{$name};
}

sub map_xy
{
    my ($self, $unit) = @_;
    return (
        int( $unit->x / $self->model->level->map->tail_width  ),
        int( $unit->y / $self->model->level->map->tail_height ),
    );
}

1;