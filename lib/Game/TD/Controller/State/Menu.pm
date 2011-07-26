use strict;
use warnings;
use utf8;

package Game::TD::Controller::State::Menu;
use base qw(Game::TD::Controller);

use SDL::Event;

use Game::TD::Config;
use Game::TD::Notify;
use Game::TD::Model::State::Menu;
use Game::TD::View::State::Menu;

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

    $self->app->add_show_handler( sub{ $self->view->draw } );

    for my $index (0 .. $#{$self->model->items})
    {
        my $name  = $self->model->items->[$index]{name};
        $self->button($name, $self->conf, $self->app );
    }

    return $self;
}

sub update
{
    return {};
}

sub event
{
    my ($self, $event) = @_;

    my %result;
    my $type = $event->type;

    for my $index (0 .. $#{$self->model->items})
    {
        my $name  = $self->model->items->[$index]{name};
        if( $self->button($name)->event_handler( $event ) eq 'up' )
        {
            $result{state} = 'board'    if $name eq 'play';
            $result{state} = 'score'    if $name eq 'score';
            $result{quit}  = 1          if $name eq 'exit';
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
        $self->button($name)->draw_handler;
    }

    return 1;
}

1;