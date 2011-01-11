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
}

sub run
{
    my ($self) = @_;

    notify 'Run';

    $self->{counter}{frame} = $self->{counter}{fps} =
    $self->{counter}{last}  = $self->{counter}{trottle} = 1;

    while (1)
    {
        # Process event queue
        $self->{event}->pump;
        $self->{event}->poll;
        my $etype = $self->{event}->type;

        # Handle user events
        last if ($etype eq SDL_QUIT );
        last if (SDL::GetKeyState(SDLK_ESCAPE));




#
#        #$app->lock() if $app->lockp();
#
#        # page flip
#
#        # __draw gfx
#
        $self->{app}->fill($self->{rect}, $SDL::Color::black);
#
#        foreach (1..$settings{numsprites})
#        {
#          put_sprite( $_*8, $y + (sin(($i+$_)*0.2)*($settings{screen_height}/3)));
#        }
#        $i+=30;

        $self->show_fps;

        # __graw gfx end
        #$app->unlock();
        $self->{app}->flip;
    }
}

sub show_fps
{
    my $self = shift;

    $self->{counter}{frame} ++;
    my $sec = int( $self->{app}->ticks / 1000 );

    if($sec > $self->{counter}{last})
    {
        $self->{counter}{fps}   = $self->{counter}{frame};
        $self->{counter}{last}  = $sec;
        $self->{counter}{frame} = 0;
    }

    my $fps = $self->{counter}{fps};
    $self->{font}->print( $self->{app}, 2, 2, "$fps fps" )
        if config->param('fps');
}

DESTROY
{
    notify 'Stop';
    notify 'Bye!';
}
1;