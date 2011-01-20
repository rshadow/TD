use strict;
use warnings;
use utf8;

package Game::TD;

use 5.10.0;
our $VERSION = 0.1;

use SDL;
use SDL::App;
use SDL::Event;

use Game::TD::Notify;
use Game::TD::Config;
use Game::TD::Controller;

=head CONSTRUCTOR

Init application

=cut

sub new
{
    my ($class, %opts) = @_;

    my $self = bless \%opts, $class;

    notify 'Init';

    $self->{app} = new SDL::App (
        -width  => WINDOW_WIDTH,
        -height => WINDOW_HEIGHT,
        -title  => 'TD',
        -icon   => config->dir('img').'/icon.png',
        -flags  => SDL_HWACCEL | SDL_DOUBLEBUF,
    );

    $self->{event} = new SDL::Event();

    # Counters
    $self->{counter}{frame} = 0;
    $self->{counter}{time}  = 0;
    $self->{counter}{fps}   = undef;
    $self->{counter}{delta} = int( 1000 / FRAMES_PER_SECOND );

    $self->{ctrl} = Game::TD::Controller->new( app => $self->app );

    return $self;
}

=head2 run

Main game loop

=cut

sub run
{
    my ($self) = @_;

    notify 'Run';

    $self->{counter}{time} = $self->app->ticks;

    while (1)
    {
        my $ticks = $self->app->ticks;

        # Process event queue
        $self->event->pump;
        $self->event->poll;
        my $etype = $self->event->type;

        # Handle user events
        last if ($etype eq SDL_QUIT );
        last if (SDL::GetKeyState(SDLK_ESCAPE));

        if ($etype eq SDL_KEYDOWN)
        {
            $self->ctrl->key_down( $self->event->key_sym );
        }
        elsif ($etype eq SDL_KEYUP)
        {
            $self->ctrl->key_up( $self->event->key_sym );
        }
        elsif($etype eq SDL_MOUSEMOTION)
        {
            $self->ctrl->mouse_motion();
        }
        elsif($etype eq SDL_MOUSEBUTTONDOWN)
        {
            $self->ctrl->mouse_button_down( $self->event->button );
        }
        elsif($etype eq SDL_MOUSEBUTTONUP)
        {
            $self->ctrl->mouse_button_up( $self->event->button );
        }

        # Update Model
        $self->ctrl->update;

        # Start draw
        $self->app->lock() if $self->app->lockp();

        $self->ctrl->draw;

        # Count FPS
        $self->{counter}{frame}++;
        if($self->app->ticks - $self->{counter}{time} >= 1000)
        {
            $self->{counter}{fps}   = $self->{counter}{frame};
            $self->{counter}{frame} = 0;
            $self->{counter}{time}  = $self->app->ticks;
        }

        # Show FPS
        $self->ctrl->draw_fps( $self->{counter}{fps} );

        # End draw
        $self->app->unlock();
        $self->app->flip;

        # Limit FPS
        my $tick = $self->app->ticks;
        my $delta = int( $self->app->ticks - $ticks );
        if($delta < $self->{counter}{delta})
        {
            $self->app->delay( $self->{counter}{delta} - $delta );

        }
    }
}

sub app     {return shift()->{app}}
sub ctrl    {return shift()->{ctrl}}
sub event   {return shift()->{event}}

DESTROY
{
    my $self = shift;

    notify 'Stop';

    delete $self->{ctrl};
    delete $self->{event};
    delete $self->{app};

    notify 'Bye!';
}
1;