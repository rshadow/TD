use strict;
use warnings;
use utf8;

package Game::TD::Controller::State::Board;
use base qw(Game::TD::Controller);

use Carp;
use SDL::Event;

use Game::TD::Config;
use Game::TD::Model::State::Board;
use Game::TD::View::State::Board;
use Game::TD::Button;

=head1 NAME

Game::TD::Controller::State::Board - Модуль

=head1 SYNOPSIS

  use Game::TD::Controller::State::Board;

=head1 DESCRIPTION

=cut

=head1 METHODS

=cut

sub new
{
    my ($class, %opts) = @_;

    die 'Missing required param "app"'      unless defined $opts{app};
    die 'Missing required param "player"'   unless defined $opts{player};

    my $self = $class->SUPER::new(%opts);

    $self->model( Game::TD::Model::State::Board->new(
        current => $self->player->level,
    ));

    $self->view( Game::TD::View::State::Board->new(
        app     => $self->app,
        model   => $self->model
    ));

    for my $level (0 .. $#{$self->model->levels})
    {
        my $name = 'level' . $level;
        my $disable = ($level <= $self->player->level) ? 0 : 1;

        $self->button($name => Game::TD::Button->new(
            name    => $name,
            app     => $self->app,
            conf    => $self->conf,
            disable => $disable,
        ));
    }

    $self->button('menu' => Game::TD::Button->new(
        name    => 'menu',
        app     => $self->app,
        conf    => $self->conf,
    ));

    return $self;
}

sub update
{
    my ($self) = @_;

    my %result;

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
        for my $index (0 .. $#{$self->model->levels})
        {
            my $name = 'level' . $index;
            $self->button($name)->event( $event );
        }
    }
    # Respond to button up state
    elsif($type == SDL_MOUSEBUTTONUP)
    {
        if( $self->button('menu')->event( $event ) eq 'up' )
        {
            $result{state} = 'menu';
        }
        else
        {
            for my $level (0 .. $#{$self->model->levels})
            {
                my $name = 'level' . $level;
                if( $self->button($name)->event( $event ) eq 'up' )
                {
                    $result{state} = 'game';
                    $result{level} = $level;
                }
            }
        }
    }

    return \%result;
}

sub draw
{
    my $self = shift;

    $self->view->draw;

    $self->button('menu')->draw;

    for my $level (0 .. $#{$self->model->levels})
    {
        my $name = 'level' . $level;
        $self->button($name)->draw;
    }

    return 1;
}

sub player
{
    return shift()->{player};
}

1;