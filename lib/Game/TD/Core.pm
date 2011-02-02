use strict;
use warnings;
use utf8;

package Game::TD::Core;

# Use raw SDL constants for events
use Exporter;
use SDL::Constants;

use Game::TD::Config;
use Game::TD::Controller::Intro;
use Game::TD::Controller::Menu;
use Game::TD::Controller::Level;

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
    $opts{state} //= 'intro';

    my $self = bless \%opts, $class;

    $self->ctrl(intro => Game::TD::Controller::Intro->new(app => $self->app));
    $self->ctrl(menu  => Game::TD::Controller::Menu->new(app => $self->app));

    my $player = Game::TD::Model::Player->new(
        name => config->param('user'=>'name')
    );
    $self->ctrl(level => Game::TD::Controller::Level->new(
        app     => $self->app,
        player  => $player,
    ));

    return $self;
}

=head2 state $state

Set state of game: intro, memu, level, game, score

=cut

sub state
{
    my ($self, $state) = @_;
    $self->{state} = $state if defined $state;
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

    return $self->ctrl( $self->state )->draw;
}

=head2 draw_fps $fps

Handler for update $fps count event

=cut

sub draw_fps
{
    my ($self, $fps) = @_;

    return $self->ctrl( $self->state )->draw_fps($fps);
}

sub event
{
    my ($self, $event) = @_;

    my $result = $self->ctrl( $self->state )->event( $event );
    my $quit  = delete $result->{quit}  if exists $result->{quit};
    my $state = delete $result->{state} if exists $result->{state};

    # Quit if controller want it
    return                           if $quit;
    # Goto next state if controller require it
    $self->state( $state, %$result ) if $state;



#    # Handle user events
#        last if ($event->type eq SDL_QUIT );
#        last if (SDL::GetKeyState(SDLK_ESCAPE));
#
#        if ($event->type eq SDL_KEYDOWN)
#        {
#            $self->core->key_down( $self->event->key_sym );
#        }
#        elsif ($event->type eq SDL_KEYUP)
#        {
#            $self->core->key_up( $self->event->key_sym );
#        }
#        elsif($event->type eq SDL_MOUSEMOTION)
#        {
#            $self->core->mouse_motion();
#        }
#        elsif($event->type eq SDL_MOUSEBUTTONDOWN)
#        {
#            $self->core->mouse_button_down( $self->event->button );
#        }
#        elsif($event->type eq SDL_MOUSEBUTTONUP)
#        {
#            $self->core->mouse_button_up( $self->event->button );
#        }

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
    die 'Name required' unless defined $name;
    delete $self->{ctrl}{$name};
}

1;