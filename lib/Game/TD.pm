use strict;
use warnings;
use utf8;

package Game::TD;

use 5.10.0;
our $VERSION = 0.2;

use SDL 2.530;
use SDL::Event;
use SDL::Surface;
use SDLx::App;
use SDLx::FPS;

use Game::TD::Notify;
use Game::TD::Config;
use Game::TD::Core;

=head CONSTRUCTOR

Init application

=cut

sub new
{
    my ($class, %opts) = @_;

    my $self = bless \%opts, $class;

    notify 'Init';

    # Create window
    $self->app( new SDLx::App (
        width           => config->param('common'=>'window'=>'width'),
        height          => config->param('common'=>'window'=>'height'),
        depth           => config->param('common'=>'window'=>'depth'),
        title           => config->param('common'=>'window'=>'title'),
        icon            => config->param('common'=>'window'=>'icon'),
        icon_title      => config->param('common'=>'window'=>'title'),
        double_buffer   => config->param('common'=>'window'=>'dbuffer'),
        fullscreen      => config->param('common'=>'window'=>'fullscreen'),
        flags           => SDL_HWACCEL,
    ));

    $self->app->dt(0.1);
    $self->app->min_t(1 / config->param('common'=>'fps'=>'value'));

    # Create game core
    $self->core( Game::TD::Core->new(app => $self->app) );

    # Events
    $self->app->add_event_handler(
        sub
        {
            my ($event, $app) = @_;
            # Quit on SDL_QUIT event
            exit if $event->type eq SDL_QUIT;
            # Quit if event handler return false
            exit unless $self->core->event( $event );

        }
    );

    # Model
    $self->app->add_move_handler(
        sub
        {
            my ($step, $app, $t) = @_;
            $self->core->update;
        }
    );

    # View
    $self->app->add_show_handler(
        sub
        {
            my ($delta, $app) = @_;
            $self->core->draw;
        }
    );

    return $self;
}

=head2 run

Run game loop

=cut

sub run
{
    my ($self) = @_;

    notify 'Run';

    $self->app->run;
}

sub app
{
    my ($self, $app) = @_;
    $self->{app} = $app if defined $app;
    return $self->{app};
}

sub core
{
    my ($self, $core) = @_;
    $self->{core} = $core if defined $core;
    return $self->{core};
}

DESTROY
{
    my $self = shift;

    notify 'Stop';

    # Delete objects
    delete $self->{core};
    delete $self->{app};

    notify 'Bye!';
}
1;