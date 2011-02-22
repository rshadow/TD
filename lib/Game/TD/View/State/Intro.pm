use strict;
use warnings;
use utf8;

package Game::TD::View::State::Intro;
use base qw(Game::TD::View);

use SDL;
use SDL::Surface;
use SDL::Rect;

use Game::TD::Config;

=head1 Game::TD::View::State::Intro

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

    $self->_init_background($self->conf);

    # Load image from file
    $self->sprite('logo' => SDLx::Sprite->new(
        image   => config->param($self->conf=>'logo'=>'file'),
    ));

    $self->sprite('logo')->rect(SDL::Rect->new(
        int(config->param($self->conf=>'logo'=>'left') -
            $self->sprite('logo')->w / 2),
        int(config->param($self->conf=>'logo'=>'top')  -
            $self->sprite('logo')->h / 2),
        $self->sprite('logo')->w,
        $self->sprite('logo')->h,
    ));

    return $self;
}

=head2

Draw intro: display image in center of window

=cut

sub draw
{
    my $self = shift;

    # Don`t update if animation complete
#    return if $self->model->alpha == 255;

    $self->sprite('logo')->alpha($self->model->alpha);

    $self->sprite('background')->draw($self->app);
    $self->sprite('logo')->draw($self->app);
}

1;
