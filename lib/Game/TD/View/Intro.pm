use strict;
use warnings;
use utf8;

package Game::TD::View::Intro;
use base qw(Game::TD::View);

use SDL;
use SDL::Surface;
use SDL::Rect;

use Game::TD::Config;

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

    my $self = $class->SUPER::new(%opts);

    # Load image from file
    $self->img(logo => SDL::Surface->new(
        -name   => config->param($self->conf=>'logo'=>'file'),
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
        -left   => int(config->param($self->conf=>'logo'=>'left') -
                     $self->img('logo')->width / 2),
        -top    => int(config->param($self->conf=>'logo'=>'top') -
                     $self->img('logo')->height / 2),
        -width  => $self->img('logo')->width,
        -height => $self->img('logo')->height
    ));

    # Draw destination - all window
    $self->dest(background => SDL::Rect->new(
        -left   => 0,
        -top    => 0,
        -width  => config->param('common'=>'window'=>'width'),
        -height => config->param('common'=>'window'=>'height')
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
    $self->{alpha} += config->param($self->conf=>'logo'=>'astep')
         if $self->{alpha} < 255 and
            !($self->model->current % $self->model->delta);
    $self->img('logo')->set_alpha(SDL_SRCALPHA, $self->{alpha});
    # Draw image
    $self->app->fill($self->dest('background'), $SDL::Color::black);
    $self->img('logo')->blit(
        $self->size('logo'), $self->app, $self->dest('logo'));
}

1;
