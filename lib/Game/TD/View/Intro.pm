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
    $self->{img} = SDL::Surface->new(
        -name   => sprintf('%s/%s', config->dir('intro'), FILE_LOGO),
        -flags  => SDL_HWSURFACE);
    $self->img->display_format;
    # Image size
    $self->{size} = SDL::Rect->new(
        -width  => $self->img->width,
        -height => $self->img->height);
    # Draw destination - center of window
    $self->{dest} = SDL::Rect->new(
        -left   => int(WINDOW_WIDTH  / 2 - $self->img->width / 2),
        -top    => int(WINDOW_HEIGHT / 2 - $self->img->height / 2),
        -width  => $self->img->width,
        -height => $self->img->height);

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
    $self->img->set_alpha(SDL_SRCALPHA, $self->{alpha});
    # Draw image
    $self->img->blit($self->size, $self->app, $self->dest);
}

sub img     {return shift()->{img}}
sub size    {return shift()->{size}}
sub dest    {return shift()->{dest}}

1;
