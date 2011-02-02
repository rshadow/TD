use strict;
use warnings;
use utf8;

package Game::TD::View::Level;
use base qw(Game::TD::View);

use SDL;
use SDL::Surface;
use SDL::Rect;

use Game::TD::Config;

=head1 Game::TD::View::Level

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
        -name   => config->param('level'=>'background'=>'file'),
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
        -width  => config->param('common'=>'window'=>'width'),
        -height => config->param('common'=>'window'=>'height')
    ));

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
}

1;