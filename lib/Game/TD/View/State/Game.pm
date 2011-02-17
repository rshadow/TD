use strict;
use warnings;
use utf8;

package Game::TD::View::State::Game;
use base qw(Game::TD::View);

use SDL;
use SDL::Surface;
use SDL::Rect;

use Game::TD::Config;

=head1 Game::TD::View::State::Game

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

    # Health counter font
    $self->font(health => SDL::TTFont->new(
        -name => config->param($self->conf=>'health'=>'font'),
        -size => config->param($self->conf=>'health'=>'size'),
        -mode => SDL::UTF8_SOLID,
        -fg   => SDL::Color->new(config->color($self->conf=>'health'=>'color')),
    ));
    $self->dest(health => SDL::Rect->new(
        -left   => config->param($self->conf=>'health'=>'fleft'),
        -top    => config->param($self->conf=>'health'=>'ftop'),
    ));

    # Score font
    $self->font(score => SDL::TTFont->new(
        -name => config->param($self->conf=>'score'=>'font'),
        -size => config->param($self->conf=>'score'=>'size'),
        -mode => SDL::UTF8_SOLID,
        -fg   => SDL::Color->new(config->color($self->conf=>'score'=>'color')),
    ));
    $self->dest(score => SDL::Rect->new(
        -left   => config->param($self->conf=>'score'=>'fleft'),
        -top    => config->param($self->conf=>'score'=>'ftop'),
    ));


    my @tiles = map {@{$_}} $self->model->map;
    for my $tile (@tiles)
    {
        my $name = $tile->{type} . $tile->{mod};
        next if defined $self->img($name);

        $self->img($name => SDL::Surface->new(
            -name   => config->param('map'=>$name=>'file'),
            -flags  => SDL_HWSURFACE
        ));

        $self->size($name => SDL::Rect->new(
            -width  => $self->img($name)->width,
            -height => $self->img($name)->height
        ));
    }

    return $self;
}

=head2 draw

Draw intro

=cut

sub draw
{
    my ($self) = @_;

    # Draw background
    $self->img('background')->blit(
        $self->size('background'), $self->app, $self->dest('background'));

    # Draw health counter
    $self->font('health')->print(
        $self->app,
        $self->dest('health')->left,
        $self->dest('health')->top,
        sprintf '%s %s',
            config->param($self->conf=>'health'=>'text') || '',
            $self->model->health,
    );

    # Draw score
    $self->font('score')->print(
        $self->app,
        $self->dest('score')->left,
        $self->dest('score')->top,
        sprintf '%s %s',
            config->param($self->conf=>'score'=>'text') || '',
            $self->model->player->score,
    );

    my @map = $self->model->map;
    for my $y (0 .. $#map )
    {
        my @line = @{ $map[$y] };
        for my $x (0 .. $#line)
        {

            my $name = $map[$x][$y]->{type} . $map[$x][$y]->{mod};

            my $dest = SDL::Rect->new(
                -left   => config->param($self->conf=>'map'=>'left') +
                           $self->img($name)->width  * $x,
                -top    => config->param($self->conf=>'map'=>'top') +
                           $self->img($name)->height * $y,
                -width  => $self->img($name)->width,
                -height => $self->img($name)->height
            );

            $self->img($name)->blit(
                $self->size($name), $self->app, $self->dest('background'));
        }
    }

}

1;