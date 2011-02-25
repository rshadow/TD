use strict;
use warnings;
use utf8;

package Game::TD::Controller::State::Intro;
use base qw(Game::TD::Controller);

use SDL::Event;

use Game::TD::Model::State::Intro;
use Game::TD::View::State::Intro;

=head1 NAME

Game::TD::Controller::State::Intro - Модуль

=head1 SYNOPSIS

  use Game::TD::Controller::State::Intro;

=head1 DESCRIPTION

=cut

=head1 METHODS

=cut

sub new
{
    my ($class, %opts) = @_;

    die 'Missing required param "app"'   unless defined $opts{app};

    my $self = $class->SUPER::new(%opts);

    $self->model( Game::TD::Model::State::Intro->new(
        app => $self->app
    ));

    $self->view( Game::TD::View::State::Intro->new(
        app     => $self->app,
        model   => $self->model
    ));

    return $self;
}

sub update
{
    my ($self) = @_;

    my %result;

    my $process = $self->model->update;
    $result{state} = 'menu' unless $process;

    return \%result;
}

sub event
{
    my ($self, $event) = @_;

    my %result;
    my $type = $event->type;

    if($type == SDL_KEYDOWN or $type == SDL_KEYUP)
    {
        # Goto Menu
        $result{state} = 'menu';
    }
    # On any key press event go to menu
    elsif($type == SDL_MOUSEBUTTONDOWN or $type == SDL_MOUSEBUTTONUP)
    {
        # Goto Menu
        $result{state} = 'menu';
    }

    return \%result;
}

1;