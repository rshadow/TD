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

    die 'Missing required param "app"'   unless defined $opts{app};
    die 'Missing required param "model"' unless defined $opts{model};

    my $self = $class->SUPER::new(%opts);

    # Load image from file
    $self->{img} = SDL::Surface->new(
        -name   => config->dir('intro').'/lmwg.png',
        -flags  => SDL_HWSURFACE);
    $self->{img}->display_format;
    # Image size
    $self->{size} = SDL::Rect->new(-height => 150, -width => 150);
    # Draw destination - center of window
    $self->{rect} = SDL::Rect->new(
        -left   => int(WINDOW_WIDTH  / 2 - 150 / 2),
        -top    => int(WINDOW_HEIGHT / 2 - 150 / 2),
        -height => 150, -width => 150 );

    # Alpha value for image animation
    $self->{alpha} = 0;

    return $self;
}

sub draw
{
    my $self = shift;
#    use Data::Dumper;
#    die Dumper $self->model;
    # Count current alpha value and set it
    unless( $self->model->current % int( $self->model->last / 255 ) )
    {
        $self->{alpha}+=5 if $self->{alpha} < 255;
    }
    $self->img->set_alpha(SDL_SRCALPHA, $self->{alpha});
    # Draw image
    $self->img->blit($self->size, $self->app, $self->rect);
    $self->font_debug->print( $self->app, 200, 2, $self->{alpha} );
}

sub app     {return shift()->{app}}
sub model    {return shift()->{model}}
sub img     {return shift()->{img}}
sub size    {return shift()->{size}}
sub rect    {return shift()->{rect}}

1;
