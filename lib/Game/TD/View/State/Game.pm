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

    # Zero coordinates for map
    my $mleft = config->param($self->conf=>'map'=>'left');
    my $mtop  = config->param($self->conf=>'map'=>'top');

    # Sleep font
    $self->font(sleep => SDL::TTFont->new(
        -name => config->param($self->conf=>'sleep'=>'font'),
        -size => config->param($self->conf=>'sleep'=>'size'),
        -mode => SDL::UTF8_SOLID,
        -fg   => SDL::Color->new(config->color($self->conf=>'sleep'=>'color')),
    ));
    $self->dest(sleep => SDL::Rect->new(
        -left   => $mleft + config->param($self->conf=>'sleep'=>'fleft'),
        -top    => $mtop +  config->param($self->conf=>'sleep'=>'ftop'),
    ));

    return $self;
}

sub _init_background
{
    my ($self, $conf) = @_;

    # Load starndart background image
    $self->SUPER::_init_background( $conf );

    # Level title font
    $self->font(title => SDL::TTFont->new(
        -name => config->param($self->conf=>'title'=>'font'),
        -size => config->param($self->conf=>'title'=>'size'),
        -mode => SDL::UTF8_SOLID,
        -fg   => SDL::Color->new(config->color($self->conf=>'title'=>'color')),
    ));
    $self->dest(title => SDL::Rect->new(
        -left   => config->param($self->conf=>'title'=>'fleft'),
        -top    => config->param($self->conf=>'title'=>'ftop'),
    ));
    # Draw title on background
    $self->font('title')->print(
        $self->img('background'),
        $self->dest('title')->left,
        $self->dest('title')->top,
        $self->model->title,
    );

    # Zero coordinates for map
    my $mleft = config->param($self->conf=>'map'=>'left');
    my $mtop  = config->param($self->conf=>'map'=>'top');

    my @map = $self->model->map;
    for my $y (0 .. $#map )
    {
        my @line = @{ $map[$y] };
        for my $x (0 .. $#line)
        {
            my $type = $map[$y][$x]->{type};
            my $mod  = $map[$y][$x]->{mod};
            my $name = $type . $mod;

            # Load map tile if not defined
            unless( defined $self->img($name) )
            {
                $self->img($name => SDL::Surface->new(
                    -name   => config->param('map'=>$type=>$mod=>'file'),
                    -flags  => SDL_SWSURFACE,
                ));

                $self->size($name => SDL::Rect->new(
                    -left   => 0,
                    -top    => 0,
                    -width  => $self->img($name)->width,
                    -height => $self->img($name)->height
                ));
            }

            # Apply map tile to background
            my $dest = SDL::Rect->new(
                -left   =>  $mleft + $self->size($name)->width  * $x,
                -top    =>  $mtop  + $self->size($name)->height * $y,
                -width  => $self->size($name)->width,
                -height => $self->size($name)->height
            );

            $self->img($name)->blit(
                $self->size($name), $self->img('background'), $dest);

            # If exists item then load it
            next unless exists $map[$y][$x]->{item};

            $type = $map[$y][$x]->{item}{type};
            $mod  = $map[$y][$x]->{item}{mod};
            $name = $type . $mod;

            # Load item tile if not defined
            unless( defined $self->img($name) )
            {
                $self->img($name => SDL::Surface->new(
                    -name   => config->param('map'=>$type=>$mod=>'file'),
                    -flags  => SDL_SWSURFACE,
                ));

                $self->size($name => SDL::Rect->new(
                    -left   => 0,
                    -top    => 0,
                    -width  => $self->img($name)->width,
                    -height => $self->img($name)->height
                ));
            }

            # Apply item tile to background
            $self->img($name)->blit(
                $self->size($name), $self->img('background'), $dest);
        }
    }
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

    if( $self->model->left > 0 )
    {
        my $text = int($self->model->left / 1000);
        $text = 'Go!' if $text < 1;

        # Draw sleep
        $self->font('sleep')->print(
            $self->app,
            $self->dest('sleep')->left,
            $self->dest('sleep')->top,
            $text,
        );

        return;
    }
}

1;