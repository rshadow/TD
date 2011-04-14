use strict;
use warnings;
use utf8;

package Game::TD::Controller::State::Menu;
use base qw(Game::TD::Controller);

use SDL::Event;

use Game::TD::Config;
use Game::TD::Model::State::Menu;
use Game::TD::View::State::Menu;
use Game::TD::Button;

=head1 NAME

Game::TD::Controller::State::Menu - Модуль

=head1 SYNOPSIS

  use Game::TD::Controller::State::Menu;

=head1 DESCRIPTION

=cut

=head1 METHODS

=cut

sub new
{
    my ($class, %opts) = @_;

    die 'Missing required param "app"'   unless defined $opts{app};

    my $self = $class->SUPER::new(%opts);

    $self->model( Game::TD::Model::State::Menu->new(
        app => $self->app
    ));

    $self->view( Game::TD::View::State::Menu->new(
        app     => $self->app,
        model   => $self->model
    ));

    for my $index (0 .. $#{$self->model->items})
    {
        my $name  = $self->model->items->[$index]{name};

        $self->button($name => Game::TD::Button->new(
            name    => $name,
            app     => $self->app,
            conf    => $self->conf,
        ));
    }

    return $self;
}

sub update
{
    my ($self) = @_;

    my %result;

#    my $process = $self->model->update;
#    $result{state} = 'menu' unless $process;

    return \%result;
}

sub event
{
    my ($self, $event) = @_;

    my %result;
    my $type = $event->type;

#    # On any key press event go to menu
#    elsif( $type == SDL_KEYDOWN         or $type == SDL_KEYUP       or
#           $type == SDL_MOUSEBUTTONDOWN or $type == SDL_MOUSEBUTTONUP)
#    {
#        # Goto Menu
#        $result{state} = 'menu';
#    }
    # Just send event to buttons
    if($type == SDL_MOUSEMOTION or $type == SDL_MOUSEBUTTONDOWN)
    {
        for my $index (0 .. $#{$self->model->items})
        {
            my $name  = $self->model->items->[$index]{name};
            $self->button($name)->event( $event );
        }
    }
    # Respond to button up state
    elsif($type == SDL_MOUSEBUTTONUP)
    {
        for my $index (0 .. $#{$self->model->items})
        {
            my $name  = $self->model->items->[$index]{name};
            if( $self->button($name)->event( $event ) eq 'up' )
            {
                $result{state} = 'board'    if $name eq 'play';
                $result{state} = 'score'    if $name eq 'score';
                $result{quit}  = 1          if $name eq 'exit';
            }
        }
    }

    return \%result;
}

sub draw
{
    my $self = shift;

    $self->view->draw;

    for my $index (0 .. $#{$self->model->items})
    {
        my $name  = $self->model->items->[$index]{name};
        $self->button($name)->draw;
    }

    return 1;
}

1;