use strict;
use warnings;
use utf8;

package Game::TD::Controller::Level;
use base qw(Game::TD::Controller);

use Carp;
use SDL;

use Game::TD::Config;
use Game::TD::Model::Level;
use Game::TD::View::Level;
use Game::TD::Button;

=head1 NAME

Game::TD::Controller::Level - Модуль

=head1 SYNOPSIS

  use Game::TD::Controller::Level;

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

    $self->model( Game::TD::Model::Level->new(
        current => $self->player->level,
    ));

    $self->view( Game::TD::View::Level->new(
        app     => $self->app,
        model   => $self->model
    ));

    for my $index (0 .. $#{$self->model->levels})
    {
        my $name = 'level' . $index;

        $self->button($name => Game::TD::Button->new(
            name    => $name,
            app     => $self->app,
            conf    => 'level',
        ));
    }

    $self->button('menu' => Game::TD::Button->new(
        name    => 'menu',
        app     => $self->app,
        conf    => 'level',
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

    # Quit if Esc
    if($type eq SDL_QUIT or SDL::GetKeyState(SDLK_ESCAPE))
    {
        $result{quit} = 1;
    }
    # Just send event to buttons
    elsif($type == SDL_MOUSEMOTION or $type == SDL_MOUSEBUTTONDOWN)
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
        my $state = $self->button('menu')->event( $event );
        if( $state eq 'up' )
        {
            $result{state} = 'menu';
        }
        else
        {
            for my $index (0 .. $#{$self->model->levels})
            {
                my $name = 'level' . $index;
                my $state = $self->button($name)->event( $event );
                if( $state eq 'up' )
                {
                    $result{state} = 'game';
                    $result{level} = $index;
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

    for my $index (0 .. $#{$self->model->levels})
    {
        my $name = 'level' . $index;
        $self->button($name)->draw;
    }

    return 1;
}

sub button
{
    my ($self, $name, $value) = @_;

    croak 'Name required'             unless defined $name;
    $self->{button}{$name} = $value   if defined $value;
    return $self->{button}{$name};
}

sub player
{
    return shift()->{player};
}

1;