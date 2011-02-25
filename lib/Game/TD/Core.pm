use strict;
use warnings;
use utf8;

package Game::TD::Core;

use Carp;
use SDL;
use SDL::Event;

use Game::TD::Config;
use Game::TD::Model::Player;

=head1 Game::TD::Model

Model for TD game

=cut

=head1 FUNCTIONS

=cut

sub new
{
    my ($class, %opts) = @_;

    die 'Missing required param "app"' unless defined $opts{app};

    my $self = bless \%opts, $class;

    # Load player info
    $self->player( Game::TD::Model::Player->new(
        name => config->param('user'=>'name')
    ));

    $self->counter('frame' => 0);
    $self->counter('time'  => $self->app->ticks);

    # Run from intro
    $self->state('intro');

    return $self;
}

=head2 state $state

Set state of game: intro, memu, level, game, score

=cut

sub state
{
    my ($self, $state, %opts) = @_;

    if( defined $state )
    {
        # Remember current state
        my $last = $self->{state};

        # Load controller for new state
        if($state eq 'intro')
        {
            require Game::TD::Controller::State::Intro;
            $self->ctrl($state =>
                Game::TD::Controller::State::Intro->new(
                    app => $self->app,
                    %opts
            ));
        }
        elsif( $state eq 'menu' )
        {
            require Game::TD::Controller::State::Menu;
            $self->ctrl($state  =>
                Game::TD::Controller::State::Menu->new(
                    app => $self->app,
                    %opts
            ));
        }
        elsif($state eq 'board')
        {
            require Game::TD::Controller::State::Board;
            $self->ctrl($state =>
                Game::TD::Controller::State::Board->new(
                    app     => $self->app,
                    player  => $self->player,
                    %opts
            ));
        }
        elsif($state eq 'game')
        {
            require Game::TD::Controller::State::Game;
            $self->ctrl($state =>
                Game::TD::Controller::State::Game->new(
                    app     => $self->app,
                    player  => $self->player,
                    %opts
            ));
        }

        # Set new state
        $self->{state} = $state;

        # Free unused controller
        $self->free( $last ) if $last;
    }

    return $self->{state};
}

=head2 update

Handler for update model event

=cut

sub update
{
    my ($self) = @_;

    # Update model
    my $result = $self->ctrl( $self->state )->update;
    # Goto next state if controller require it
    $self->state( $result->{state} ) if $result->{state};

    return 1;
}

=head2 draw

Handler for update view event

=cut

sub draw
{
    my $self = shift;

    $self->ctrl( $self->state )->draw;

    if( config->param(user => 'showfps') )
    {
        $self->counter( 'frame' => ($self->counter('frame') + 1) );
        if($self->app->ticks - $self->counter('time') >= 1000)
        {
            $self->fps( $self->counter('frame') );
            $self->counter('frame' => 0);
            $self->counter('time' => $self->app->ticks);
        }

        $self->ctrl( $self->state )->draw_fps($self->fps);
    }

    $self->app->flip;
}

sub event
{
    my ($self, $event) = @_;

    my $type = $event->type;

    # Common events
    if($type == SDL_QUIT)
    {
        return;
    }
    elsif($type == SDL_KEYDOWN)
    {
        my $sym = $event->key_sym;
        my $mod = $event->key_mod;

        # ESC exit from game
        if($sym == SDLK_ESCAPE)
        {
            return;
        }
        # Ctrl+F toggle fullscreen mode
        elsif($sym == SDLK_f && $mod & KMOD_CTRL)
        {
            $self->app->fullscreen;
        }
    }
    # Game events
    else
    {
        my $result = $self->ctrl( $self->state )->event( $event );
        my $quit  = delete $result->{quit}  if exists $result->{quit};
        my $state = delete $result->{state} if exists $result->{state};

        # Quit if controller want it
        return                           if $quit;
        # Goto next state if controller require it
        $self->state( $state, %$result ) if $state;
    }

    return 1;
}

=head2 app

Get SDL App object

=cut

sub app
{
    return shift()->{app}
}

=head2 view $name, $value

Set view object $name if set $value or return if $value not set.

=cut

sub ctrl
{
    my ($self, $name, $value) = @_;

    die 'Name required'             unless defined $name;
    $self->{ctrl}{$name} = $value   if defined $value;
    return $self->{ctrl}{$name};
}

sub free
{
    my ($self, $name) = @_;
    croak 'Name required' unless defined $name;
    delete $self->{ctrl}{$name};
}

sub player
{
    my ($self, $player) = @_;
    $self->{player} = $player if defined $player;
    return $self->{player};
}

sub fps
{
    my ($self, $fps) = @_;
    $self->{fps} = $fps if defined $fps;
    return $self->{fps};
}

sub counter
{
    my ($self, $name, $value) = @_;
    croak 'Name required' unless defined $name;
    $self->{counter}{$name} = $value if defined $value;
    return $self->{counter}{$name};
}

1;