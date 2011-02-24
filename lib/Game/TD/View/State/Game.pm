use strict;
use warnings;
use utf8;

package Game::TD::View::State::Game;
use base qw(Game::TD::View);

use Carp;
use SDL;
use SDLx::Sprite;
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

    $self->_init_background;

    # Health counter font
    $self->font(health => SDLx::Text->new(
        font    => config->param($self->conf=>'health'=>'font'),
        size    => config->param($self->conf=>'health'=>'size'),
        color   => config->color($self->conf=>'health'=>'color'),
        mode    => 'utf8',
    ));
    $self->dest(health => SDL::Rect->new(
        config->param($self->conf=>'health'=>'fleft'),
        config->param($self->conf=>'health'=>'ftop'),
        0 ,0
    ));

    # Score font
    $self->font(score => SDLx::Text->new(
        font    => config->param($self->conf=>'score'=>'font'),
        size    => config->param($self->conf=>'score'=>'size'),
        color   => config->color($self->conf=>'score'=>'color'),
        mode    => 'utf8',
    ));
    $self->dest(score => SDL::Rect->new(
        config->param($self->conf=>'score'=>'fleft'),
        config->param($self->conf=>'score'=>'ftop'),
        0 ,0
    ));

    # Zero coordinates for map
    my $mleft = config->param($self->conf=>'map'=>'left');
    my $mtop  = config->param($self->conf=>'map'=>'top');

    # Sleep font
    $self->font(sleep => SDLx::Text->new(
        font    => config->param($self->conf=>'sleep'=>'font'),
        size    => config->param($self->conf=>'sleep'=>'size'),
        color   => config->color($self->conf=>'sleep'=>'color'),
        mode    => 'utf8',
        h_align => 'center',
    ));
    $self->dest(sleep => SDL::Rect->new(
        $mleft + config->param($self->conf=>'sleep'=>'fleft'),
        $mtop  + config->param($self->conf=>'sleep'=>'ftop'),
        0 ,0
    ));

    return $self;
}

sub _init_background
{
    my ($self, $conf) = @_;

    # Load starndart background image
    $self->SUPER::_init_background( $self->conf );

    # Level title font
    $self->font(title => SDLx::Text->new(
        font    => config->param($self->conf=>'title'=>'font'),
        size    => config->param($self->conf=>'title'=>'size'),
        color   => config->color($self->conf=>'title'=>'color'),
        mode    => 'utf8',
    ));
    $self->dest(title => SDL::Rect->new(
        config->param($self->conf=>'title'=>'fleft'),
        config->param($self->conf=>'title'=>'ftop'),
        0 ,0
    ));
    # Draw title on background
    $self->font('title')->write_xy(
        $self->sprite('background')->surface,
        $self->dest('title')->x,
        $self->dest('title')->y,
        $self->model->level->title,
    );

    # Zero coordinates for map
    my $mleft = config->param($self->conf=>'map'=>'left');
    my $mtop  = config->param($self->conf=>'map'=>'top');

    my @map = $self->model->level->map;

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
    unless( defined $self->sprite($name) )
    {
        $self->sprite($name => SDLx::Sprite->new(
            image => config->param('map'=>$type=>$mod=>'file'),
        ));
    }

    my $dx = int(($self->sprite($name)->w - $self->model->level->tail_width)  / 2);
    my $dy = int(($self->sprite($name)->h - $self->model->level->tail_height) / 2);

    $self->sprite($name)->rect(SDL::Rect->new(
        $mleft + $self->model->level->tail_width  * $x - $dx,
        $mtop  + $self->model->level->tail_height * $y - $dy,
        $self->sprite($name)->w,
        $self->sprite($name)->h
    ));

    # Apply item tile to background
    $self->sprite($name)->draw( $self->sprite($to)->surface );
}

=head2 draw

Draw intro

=cut

sub draw
{
    my ($self) = @_;

    # Draw background
    $self->sprite('background')->draw( $self->app );

    # Draw health counter
    $self->font('health')->write_xy(
        $self->app,
        $self->dest('health')->x,
        $self->dest('health')->y,
        sprintf '%s %s',
            config->param($self->conf=>'health'=>'text') || '',
            $self->model->level->health,
    );

    # Draw score
    $self->font('score')->write_xy(
        $self->app,
        $self->dest('score')->x,
        $self->dest('score')->y,
        sprintf '%s %s',
            config->param($self->conf=>'score'=>'text') || '',
            $self->model->player->score,
    );

    if( $self->model->left > 0 )
    {
        my $text = int($self->model->left / 1000);
        $text = 'Go!' if $text < 1;

        # Draw sleep
#        $self->font('sleep')->text($text);
        $self->font('sleep')->write_to(
            $self->app,
#            $self->font('sleep')->x,
#            $self->font('sleep')->y,
            $text
        );

        return;
    }
}

1;