use strict;
use warnings;
use utf8;

package Game::TD;

use 5.10.0;
our $VERSION = 0.2;

use SDL 2.530;
use SDL::Surface;
use SDLx::App;

use Game::TD::Notify;
use Game::TD::Config;
use Game::TD::Core;

use constant TICKS_PER_SEC  => 1000;

=head CONSTRUCTOR

Init application

=cut

sub new
{
    my ($class, %opts) = @_;

    my $self = bless \%opts, $class;

    notify 'Init';

    # Create window
    $self->{app} = new SDLx::App (
        width  => config->param('common'=>'window'=>'width'),
        height => config->param('common'=>'window'=>'height'),
        depth  => config->param('common'=>'window'=>'depth'),
        title  => config->param('common'=>'window'=>'title'),
        icon   => config->param('common'=>'window'=>'icon'),
        icon_title     => config->param('common'=>'window'=>'title'),
        double_buffer  => (config->param('common'=>'window'=>'dbuffer') || 0),
        fullscreen => (config->param('common'=>'window'=>'fullscreen') || 0),
        flags      => SDL_HWACCEL,
#        asyncblit  => 1,
    );
#    $self->app->display_format;

    $self->app->dt(0.1);
    $self->app->min_t(1 / config->param('common'=>'fps'=>'value'));

    # Counters
#    $self->{counter}{frame} = 0;
#    $self->{counter}{time}  = 0;
#    $self->{counter}{fps}   = undef;
#    $self->{counter}{delta} =
#        int( TICKS_PER_SEC / config->param('common'=>'fps'=>'value') );

    # Create game core
    $self->{core} = Game::TD::Core->new( app => $self->app );

    # Events
    $self->app->add_event_handler(
        sub {
            my ($event, $app) = @_;
            $self->core->event( $event );
        }
    );

    # Update model
    $self->app->add_move_handler(
        sub {
            my ($step, $app, $t) = @_;
            $self->core->update;
        }
    );

    # Draw game
    $self->app->add_show_handler(
        sub {
            my ($delta, $app) = @_;
            $self->core->draw;
        }
    );

    # Draw FPS
    $self->app->add_show_handler(
        sub {
            my ($delta, $app) = @_;
            $self->core->draw_fps(  );
        }
    ) if config->param(user => 'showfps');

    # Draw on screen
    $self->app->add_show_handler(
        sub {
            my ($delta, $app) = @_;
            $app->flip;
        }
    );

    return $self;
}

=head2 run

Main game loop

=cut

sub run
{
    my ($self) = @_;
    $self->app->run;
}

#sub run
#{
#    my ($self) = @_;
#
#    notify 'Run';
#
#    $self->{counter}{time} = $self->app->ticks;
#    my $quit = 0;
#
#    while (1)
#    {
#        my $ticks = $self->app->ticks;
#
#        # Process event queue
#        $self->event->pump;
#        while( $self->event->poll )
#        {
#            # Quit if event handler return false
#            $quit = 1 unless $self->core->event( $self->event );
#            # Quit on SDL_QUIT event
#            $quit = 1 if $self->event->type eq SDL_QUIT;
#        }
#        last if $quit;
#
#        # Update Model
#        $self->core->update;
#
#        # Start draw
#        $self->app->lock() if $self->app->lockp();
#
#        $self->core->draw;
#
#        # Count FPS
#        $self->{counter}{frame}++;
#        if($self->app->ticks - $self->{counter}{time} >= TICKS_PER_SEC)
#        {
#            $self->fps( $self->{counter}{frame} );
#            $self->{counter}{frame} = 0;
#            $self->{counter}{time}  = $self->app->ticks;
#        }
#
#        # Show FPS
#        $self->core->draw_fps( $self->fps );
#
#        # End draw
#        $self->app->unlock();
#        $self->app->sync;
#
#        # Limit FPS
#        my $tick = $self->app->ticks;
#        my $delta = int( $self->app->ticks - $ticks );
#        if($delta < $self->{counter}{delta})
#        {
#            $self->app->delay( $self->{counter}{delta} - $delta );
#
#        }
#    }
#}

sub app     {return shift()->{app}}
sub core    {return shift()->{core}}

#sub fps
#{
#    my ($self, $fps) = @_;
#    $self->{counter}{fps} = $fps if defined $fps;
#    return $self->{counter}{fps};
#}

DESTROY
{
    my $self = shift;

    notify 'Stop';

    # Stop executing
    $self->app->remove_all_handlers;
    # Delete objects
    delete $self->{core};
    delete $self->{app};

    notify 'Bye!';
}
1;