use strict;
use warnings;
use utf8;

package Game::TD::View::Game;
use base qw(Game::TD::View);

use SDL;
use SDL::Surface;
use SDL::Rect;

use Game::TD::Config;

=head1 Game::TD::View::Game

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

    my $self = $class->SUPER::new(%opts);

    $self->_init_background($self->conf);

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