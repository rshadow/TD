use strict;
use warnings;
use utf8;

package Game::TD::View::Intro;
use base qw(Game::TD::View);

use SDL;
use SDL::Surface;
use SDL::Rect;

use Game::TD::Config;

# Step for alpha blending
use constant ALPHA_STEP => 5;
# Logo file
use constant FILE_LOGO => 'lmwg.png';

=head1 Game::TD::View::Intro

Display intro

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

    # Load image from file
    $self->img(logo => SDL::Surface->new(
        -name   => sprintf('%s/%s', config->dir('intro'), FILE_LOGO),
        -flags  => SDL_HWSURFACE
    ));
    $self->img('logo')->display_format;
    # Image size
    $self->size(logo => SDL::Rect->new(
        -width  => $self->img('logo')->width,
        -height => $self->img('logo')->height
    ));
    # Draw destination - center of window
    $self->dest(logo => SDL::Rect->new(
        -left   => int(WINDOW_WIDTH  / 2 - $self->img('logo')->width / 2),
        -top    => int(WINDOW_HEIGHT / 2 - $self->img('logo')->height / 2),
        -width  => $self->img('logo')->width,
        -height => $self->img('logo')->height
    ));

    # Draw destination - all window
    $self->dest(background => SDL::Rect->new(
        -left   => 0,
        -top    => 0,
        -width  => WINDOW_WIDTH,
        -height => WINDOW_HEIGHT
    ));

    # Alpha value for image animation
    $self->{alpha} = 0;

    return $self;
}

=head2

Draw intro: display image in center of window

=cut

sub draw
{
    my $self = shift;
    # Count current alpha value for each frame and set it
    $self->{alpha} += ALPHA_STEP if $self->{alpha} < 255 and
        !($self->model->current % $self->model->delta);
    $self->img('logo')->set_alpha(SDL_SRCALPHA, $self->{alpha});
    # Draw image
    $self->app->fill($self->dest('background'), $SDL::Color::black);
    $self->img('logo')->blit(
        $self->size('logo'), $self->app, $self->dest('logo'));
}

1;
