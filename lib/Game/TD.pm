use strict;
use warnings;
use utf8;

package Game::TD;

use 5.10.0;

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
use Game::TD::Model;

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
        -width  => 800,
        -height => 600,
        -title  => "TD",
#       -icon  => "data/icon.bmp",
        -flags  => SDL_HWACCEL | SDL_DOUBLEBUF,
    );
    $self->{rect} = new SDL::Rect(
        -width  => 800,
        -height => 600,
    );

    $self->{app}->fill($self->{rect}, $SDL::Color::black);

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
    $self->{counter}{delta} =
        (config->param('fps')) ?int( 1000 / config->param('fps') ) :0;

    $self->{model} = Game::TD::Model->new;

}

sub run
{
    my ($self) = @_;

    notify 'Run';

    $self->{counter}{time} = $self->{app}->ticks;

    while (1)
    {
        my $ticks = $self->{app}->ticks;

        # Process event queue
        $self->{event}->pump;
        $self->{event}->poll;
        my $etype = $self->{event}->type;

        # Handle user events
        last if ($etype eq SDL_QUIT );
        last if (SDL::GetKeyState(SDLK_ESCAPE));
        if ($etype eq SDL_KEYDOWN)
        {
            if( $self->{event}->key_sym == SDLK_UP )
            {
                $self->{model}->key_up;
            }
            elsif( $self->{event}->key_sym == SDLK_DOWN )
            {
                $self->{model}->key_down;
            }
        }

        # Update Model
        $self->{model}->update;

        # Start draw
        $self->{app}->lock() if $self->{app}->lockp();

        $self->{app}->fill($self->{rect}, $SDL::Color::black);

        # Count FPS
        $self->{counter}{frame}++;
        if($self->{app}->ticks - $self->{counter}{time} >= 1000)
        {
            $self->{counter}{fps}   = $self->{counter}{frame};
            $self->{counter}{frame} = 0;
            $self->{counter}{time}  = $self->{app}->ticks;
        }

        # Show FPS
        $self->{font}->print(
            $self->{app},
            2, 2,
            sprintf '%d fps', $self->{counter}{fps} )
                if config->param('showfps') and defined $self->{counter}{fps};

        # End draw
        $self->{app}->unlock();
        $self->{app}->flip;

        # Limit FPS
        if( config->param('fps') )
        {
            my $tick = $self->{app}->ticks;
            my $delta = int( $self->{app}->ticks - $ticks );
            if($delta < $self->{counter}{delta})
            {
                $self->{app}->delay( $self->{counter}{delta} - $delta );

            }
        }
    }
}

DESTROY
{
    notify 'Stop';
    notify 'Bye!';
}
1;