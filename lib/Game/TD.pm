use strict;
use warnings;
use utf8;

package Game::TD;

use 5.10.0;
our $VERSION = 0.1;

use SDL;
use SDL::App;
use SDL::Event;
use SDL::Surface;
use SDL::Color;
use SDL::Rect;

use SDL::TTFont;

use Data::Dumper;

use Game::TD::Notify;
use Game::TD::Config;
use Game::TD::Controller;

sub new
{
    my ($class, %opts) = @_;

    my $self = bless \%opts, $class;

    $self->_init;

    return $self;
}

=head2 _init

=cut

sub _init
{
    my ($self) = @_;

    notify 'Init';

    $self->{app} = new SDL::App (
        -width  => WINDOW_WIDTH,
        -height => WINDOW_HEIGHT,
        -title  => "TD",
#       -icon  => "data/icon.bmp",
        -flags  => SDL_HWACCEL | SDL_DOUBLEBUF,
    );
    $self->{rect} = new SDL::Rect(
        -width  => WINDOW_WIDTH,
        -height => WINDOW_HEIGHT,
    );

    $self->app->fill($self->{rect}, $SDL::Color::black);

    $self->{font} = SDL::TTFont->new(
        -name => "/usr/share/fonts/truetype/msttcorefonts/Verdana.ttf",
        -size => '12',
        -mode => SDL::UTF8_SOLID,
        -fg     => $SDL::Color::red,
    );
#    $font->use();

    $self->{event} = new SDL::Event();

    # Counters
    $self->{counter}{frame} = 0;
    $self->{counter}{time}  = 0;
    $self->{counter}{fps}   = undef;
    $self->{counter}{delta} = int( 1000 / FRAMES_PER_SECOND );

    $self->{ctrl} = Game::TD::Controller->new( app => $self->app );
}

sub run
{
    my ($self) = @_;

    notify 'Run';

    $self->{counter}{time} = $self->app->ticks;

    while (1)
    {
        my $ticks = $self->app->ticks;

        # Process event queue
        $self->{event}->pump;
        $self->{event}->poll;
        my $etype = $self->{event}->type;

        # Handle user events
        last if ($etype eq SDL_QUIT );
        last if (SDL::GetKeyState(SDLK_ESCAPE));
        if ($etype eq SDL_KEYDOWN)
        {
            my $key_sym = $self->{event}->key_sym;
            if( $key_sym == SDLK_UP )
            {
                $self->{ctrl}->key_up;
            }
            elsif( $key_sym == SDLK_DOWN )
            {
                $self->{ctrl}->key_down;
            }
            elsif( $key_sym == SDLK_RETURN or $key_sym == SDLK_SPACE)
            {
                $self->{ctrl}->key_any;
            }
        }

        # Update Model
        $self->ctrl->update;

        # Start draw
        $self->app->lock() if $self->app->lockp();

        $self->app->fill($self->{rect}, $SDL::Color::black);

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

DESTROY
{
    my $self = shift;

    notify 'Stop';

    delete $self->{app};
    delete $self->{ctrl};

    notify 'Bye!';
}
1;