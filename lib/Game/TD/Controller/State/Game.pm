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
use Game::TD::Model::Panel;
use Game::TD::Button;

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

    $opts{pause} //= 0;

    my $self = $class->SUPER::new(%opts);

    $self->model( Game::TD::Model::State::Game->new(
        num     => $opts{level},
        player  => $self->player,
        dt      => $self->app->dt,
    ));

    $self->panel( Game::TD::Model::Panel->new(
        visible => 1,
    ));

    $self->view( Game::TD::View::State::Game->new(
        app     => $self->app,
        model   => $self->model
    ));

    $self->button('menu' => Game::TD::Button->new(
        name    => 'menu',
        app     => $self->app,
        conf    => $self->conf,
        parent  => $self->view->sprite('panel'),
    ));

    $self->button('pause' => Game::TD::Button->new(
        name    => 'pause',
        app     => $self->app,
        conf    => $self->conf,
        parent  => $self->view->sprite('panel'),
    ));

    my @names = keys %{ config->param('tower') };
    for my $tower ( @names )
    {
        $self->button($tower => Game::TD::Button->new(
            name    => $tower,
            app     => $self->app,
            conf    => $self->conf,
            file    => config->param('tower'=>$tower=>'button'=>'file'),
            parent  => $self->view->sprite('panel'),
        ));
    }

    return $self;
}

sub update
{
    my ($self) = @_;

    my %result;

    return \%result if $self->is_pause;

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
    if($type == SDL_MOUSEMOTION)
    {
        # Send to buttons
        $self->button('menu')->event( $event );
        $self->button('pause')->event( $event );

        my @names = keys %{ config->param('tower') };
        $self->button($_)->event( $event ) for @names;

        # Get mouse position and screen params
        my $x       = $event->motion_x;
        my $y       = $event->motion_y;
        my $width   = $self->app->surface->w;
        my $height  = $self->app->surface->h;
        # Sensetive border
        my $border  = config->param('common'=>'camera'=>'border');

        # Scroll camera on mouse
        ($x <= $border)
            ? $self->model->camera->move('left')
            : $self->model->camera->stop('left');
        ($x >= ($width-$border))
            ? $self->model->camera->move('right')
            : $self->model->camera->stop('right');
        ($y <= $border)
            ? $self->model->camera->move('up')
            : $self->model->camera->stop('up');
        ($y >= ($height-$border))
            ? $self->model->camera->move('down')
            : $self->model->camera->stop('down');
    }
    elsif($type == SDL_MOUSEBUTTONDOWN)
    {
        # Send to buttons
        $self->button('menu')->event( $event );
        $self->button('pause')->event( $event );

        my @names = keys %{ config->param('tower') };
        $self->button($_)->event( $event ) for @names;
    }
    # Respond to button up state
    elsif($type == SDL_MOUSEBUTTONUP)
    {
        if( $self->button('menu')->event( $event ) eq 'up' )
        {
            $result{state} = 'menu';
        }

        if( $self->button('pause')->event( $event ) eq 'up' )
        {
            $self->pause;
        }

        my @names = keys %{ config->param('tower') };
        for my $name ( @names )
        {
            if( $self->button($name)->event( $event ) eq 'up' )
            {
            }
        }
    }
    elsif($type == SDL_KEYDOWN)
    {
        my $sym = $event->key_sym;

        if($sym == SDLK_PAUSE    || $sym == SDLK_p)
        {
            $self->pause;
        }
        elsif($sym == SDLK_UP    || $sym == SDLK_w)
        {
            $self->model->camera->move('up');
        }
        elsif($sym == SDLK_LEFT  || $sym == SDLK_a)
        {
            $self->model->camera->move('left');
        }
        elsif($sym == SDLK_DOWN  || $sym == SDLK_s)
        {
            $self->model->camera->move('down');
        }
        elsif($sym == SDLK_RIGHT || $sym == SDLK_d)
        {
            $self->model->camera->move('right');
        }
    }
    elsif($type == SDL_KEYUP)
    {
        my $sym = $event->key_sym;

        if($sym == SDLK_UP    || $sym == SDLK_w)
        {
            $self->model->camera->stop('up');
        }
        elsif($sym == SDLK_LEFT  || $sym == SDLK_a)
        {
            $self->model->camera->stop('left');
        }
        elsif($sym == SDLK_DOWN  || $sym == SDLK_s)
        {
            $self->model->camera->stop('down');
        }
        elsif($sym == SDLK_RIGHT || $sym == SDLK_d)
        {
            $self->model->camera->stop('right');
        }
    }

    return \%result;
}

sub draw
{
    my $self = shift;

    unless( $self->is_pause )
    {
        $self->view->prepare;

        my @names = keys %{ config->param('tower') };
        $self->button($_)->draw for @names;
    }

    $self->button('menu')->draw;
    $self->button('pause')->draw;

    $self->view->draw;

    return 1;
}

=head2 player

Return player object

=cut

sub player
{
    return shift()->{player};
}

=head2 panel $value

Set panel object if set $value or return if $value not set.

=cut

sub panel
{
    my ($self, $value) = @_;

    $self->{panel} = $value  if defined $value;
    return $self->{panel};
}

sub is_pause
{
    my $self = shift;
    return $self->{pause};
}

sub pause
{
    my $self = shift;
    $self->{pause} = not $self->{pause};

    # TODO: Pause timers

    return $self->{pause};
}

1;