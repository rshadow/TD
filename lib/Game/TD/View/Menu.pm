use strict;
use warnings;
use utf8;

package Game::TD::View::Menu;
use base qw(Game::TD::View);

use SDL;
use SDL::Surface;
use SDL::Rect;

use Game::TD::Config;

# Background file
use constant FILE_BG => 'background.jpg';

=head1 Game::TD::View::Menu

Описание_модуля

=cut

=head1 Функции

=cut

=head2 new HASH

Конструктор

=head3 Входные параметры

=head4 параметр

=cut

sub new
{
    my ($class, %opts) = @_;

    die 'Missing required param "app"'   unless defined $opts{app};
    die 'Missing required param "model"' unless defined $opts{model};

    my $self = $class->SUPER::new(%opts);

    # Load background image from file
    $self->img( background => SDL::Surface->new(
        -name   => sprintf('%s/%s', config->dir('menu'), FILE_BG),
        -flags  => SDL_HWSURFACE
    ));
    $self->img('background')->display_format;
    # Image size
    $self->size(background => SDL::Rect->new(
        -width  => $self->img('background')->width,
        -height => $self->img('background')->height
    ));
    # Draw destination - all window
    $self->dest(background => SDL::Rect->new(
        -left   => 0,
        -top    => 0,
        -width  => WINDOW_WIDTH,
        -height => WINDOW_HEIGHT
    ));

    for my $index (0 .. $#{$self->model->items})
    {
        my $item = $self->model->items->[$index]{name};

        # Load menu item image from file
        $self->img($item => SDL::Surface->new(
            -name   => sprintf('%s/%s.png', config->dir('menu'), $item)
        ));
#        $self->{img}{$item}->display_format;

        # Image size (in every image 3 stage: normal, current, pressed)
        my $width  = int( $self->img($item)->width / 3 );
        my $height = $self->img($item)->height;

        $self->size($item.'_normal' => SDL::Rect->new(
            -left  => 0,            -top => 0,
            -width => $width,       -height => $height
        ));
        $self->size($item.'_current' => SDL::Rect->new(
            -left  => $width,       -top => 0,
            -width => $width,       -height => $height
        ));
        $self->size($item.'_pressed' => SDL::Rect->new(
            -left  => $width * 2,   -top    => 0,
            -width => $width,       -height => $height
        ));

        # Draw destination
        $self->dest($item => SDL::Rect->new(
            -left   => WINDOW_WIDTH - 10 - $width,
            -top    => 0 + 10 * $index + $height * $index,
            -width  => $width,
            -height => $height
        ));
    }

    $self->font(menu => SDL::TTFont->new(
        -name => "/usr/share/fonts/type1/gsfonts/a010013l.pfb",
        -size => '56',
        -mode => SDL::UTF8_SOLID,
        -fg   => $SDL::Color::white,
    ));

#    # Load font for draw version
#    $self->{font}{version} = SDL::TTFont->new(
#        -name => "/usr/share/fonts/type1/gsfonts/a010013l.pfb",
#        -size => '24',
#        -mode => SDL::UTF8_BLENDED,
#        -fg   => $SDL::Color::white,
#    );
#    $self->{font}{version}->bold;
#
#    # Image for draw version in alpha
#    $self->{img}{version} = SDL::Surface->new(
#        -flags  => SDL_ANYFORMAT,
#        -width  => WINDOW_WIDTH,
#        -height => $self->{font}{version}->height,
##        -depth  => $self->{img}{background}->bpp
#    );
##    $self->{img}{version}->fill();
#    $self->{img}{version}->set_color_key(SDL_SRCCOLORKEY, $SDL::Color::black);
#    $self->{img}{version}->set_alpha(SDL_SRCALPHA, 150);
#    $self->{font}{version}->print($self->{img}{version},
#        0, 0,
#        sprintf('version %s', $self->model->version)
#    );
#    $self->{size}{version} = SDL::Rect->new(
#        -left   => 0,
#        -top    => 0,
#        -width  => $self->{img}{version}->width,
#        -height => $self->{img}{version}->height );
#    # Draw destination for version
#    $self->{dest}{version} = SDL::Rect->new(
#        -left   => 10,
#        -top    => WINDOW_HEIGHT - $self->{font}{version}->height - 2);

    return $self;
}

=head2 draw_intro

Draw intro

=cut

sub draw
{
    my ($self) = @_;

    # Draw background
    $self->img('background')->blit(
        $self->size('background'), $self->app, $self->dest('background'));

    # Draw items
    for my $index (0 .. $#{$self->model->items})
    {
        my $item  = $self->model->items->[$index]{name};
        my $title = $self->model->items->[$index]{title};

        $self->img($item)->blit(
            $self->size($item.'_normal'), $self->app, $self->dest($item));

        $self->{font}{menu}->print(
            $self->app,
            $self->dest($item)->left,
            $self->dest($item)->top,
            $title
        );
    }

    # Draw version
#    $self->{img}{version}->blit(
#        $self->{size}{version}, $self->app, $self->{dest}{version});
#

#    $self->{font}{version}->print(
#            $self->app,
#            300,
#            300,
#            $self->model->version
#        );
}

1;