use strict;
use warnings;
use utf8;

package Game::TD::View::State::Game;
use base qw(Game::TD::View);

use Carp;
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

    # Draw map tiles on background
    for my $y (0 .. $#map )
    {
        my @line = @{ $map[$y] };
        for my $x (0 .. $#line)
        {
            $self->_draw_map_tile(
                to      => 'background',
                type    => $map[$y][$x]->{type},
                mod     => $map[$y][$x]->{mod},
                mleft   => $mleft,
                mtop    => $mtop,
                x       => $x,
                y       => $y,
            );
        }
    }

    # Draw items on background
    for my $y (0 .. $#map )
    {
        my @line = @{ $map[$y] };
        for my $x (0 .. $#line)
        {
            # If exists item then load it
            next unless exists $map[$y][$x]->{item};

            $self->_draw_map_tile(
                to      => 'background',
                type    => $map[$y][$x]->{item}{type},
                mod     => $map[$y][$x]->{item}{mod},
                mleft   => $mleft,
                mtop    => $mtop,
                x       => $x,
                y       => $y,
            );
        }
    }
}

sub _draw_map_tile
{
    my ($self, %tile) = @_;

    croak 'Missing required parameter "to"'     unless defined $tile{to};
    croak 'Missing required parameter "type"'   unless defined $tile{type};
    croak 'Missing required parameter "mod"'    unless defined $tile{mod};
    croak 'Missing required parameter "x"'      unless defined $tile{x};
    croak 'Missing required parameter "y"'      unless defined $tile{y};

    # Name of destanation surface
    my $to      = $tile{to};
    # Tile type
    my $type    = $tile{type};
    my $mod     = $tile{mod};
    # Logical coordinates
    my $x       = $tile{x};
    my $y       = $tile{y};
    # Map shift
    my $mleft   = $tile{mleft} || 0;
    my $mtop    = $tile{mtop}  || 0;

    my $name = $type . $mod;

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

    my $dx =
        int(($self->size($name)->width  - $self->model->tail_width)/2);
    my $dy =
        int(($self->size($name)->height - $self->model->tail_height)/2);

    my $dest = SDL::Rect->new(
        -left   =>  $mleft + $self->model->tail_width  * $x - $dx,
        -top    =>  $mtop  + $self->model->tail_height * $y - $dy,
        -width  => $self->size($name)->width,
        -height => $self->size($name)->height
    );

    my $src = SDL::Rect->new(
        -left   => $self->size($name)->left,
        -top    => $self->size($name)->top,
        -width  => $self->size($name)->width,
        -height => $self->size($name)->height
    );

#            if($type eq 'tree')
#            {
#                printf "%s:%s \t dx=%s, dy=%s \t src=%s:%s,%sx%s \t dest:%s:%s,%s:%s\n",
#                    $x, $y, $dx, $dy,
#
#                    $src->left, $src->top, $src->width, $src->height,
#                    $dest->left, $dest->top, $dest->width, $dest->height;
#            }

    # Apply item tile to background
    $self->img($name)->blit($src, $self->img($to), $dest);
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