use strict;
use warnings;
use utf8;

package Game::TD::View::State::Game;
use base qw(Game::TD::View);

use Carp;
use SDL;
use SDL::Rect;
use SDLx::Sprite;
use SDLx::Text;

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
    $self->_init_map;
    $self->_init_editor if config->param('editor'=>'enable');
    $self->_init_items;
    $self->_init_units;


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

    # Sleep font
    $self->font(sleep => SDLx::Text->new(
        font    => config->param($self->conf=>'sleep'=>'font'),
        size    => config->param($self->conf=>'sleep'=>'size'),
        color   => config->color($self->conf=>'sleep'=>'color'),
        mode    => 'utf8',
        h_align => 'center',
    ));
    $self->dest(sleep => SDL::Rect->new(
        $self->model->camera->left + $self->model->map->tail_map_width  / 2,
        $self->model->camera->top  + $self->model->map->tail_map_height / 2,
        0 ,0
    ));

    return $self;
}

sub _init_background
{
    my ($self) = @_;
    $self->SUPER::_init_background;

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
    # Draw title on map
    $self->font('title')->write_xy(
        $self->sprite('background')->surface,
        $self->dest('title')->x,
        $self->dest('title')->y,
        $self->model->title,
    );
}

sub _init_map
{
    my ($self) = @_;

    $self->sprite('map' => SDLx::Sprite->new(
        clip    => $self->model->camera->clip,
        rect    => $self->model->camera->rect,
        width   => $self->model->map->tail_map_width,
        height  => $self->model->map->tail_map_height,
    ));

    # Init map by filling color
    $self->sprite('map')->surface->draw_rect(
        SDL::Rect->new(
            0, 0,
            $self->model->map->tail_map_width,
            $self->model->map->tail_map_height),
        0xFFFF00FF
    );

    # Draw tiles on map
    for my $y (0 .. ($self->model->map->height - 1) )
    {
        for my $x (0 .. ($self->model->map->width - 1))
        {
            my $tail = $self->model->map->tail($x,$y);

            $self->_draw_map_tile(
                to      => 'map',
                type    => $tail->{type},
                mod     => $tail->{mod},
                x       => $x,
                y       => $y,
            );
        }
    }
}

sub _init_items
{
    my ($self) = @_;

    # Draw items on background
    for my $y (0 .. ($self->model->map->height - 1) )
    {
        for my $x (0 .. ($self->model->map->width - 1))
        {
            my $tail = $self->model->map->tail($x,$y);

            # If exists item then load it
            next unless exists $tail->{item};

            $self->_draw_map_tile(
                to      => 'map',
                type    => $tail->{item}{type},
                mod     => $tail->{item}{mod},
                x       => $x,
                y       => $y,
            );
        }
    }
}

sub _init_units
{
    my ($self) = @_;

    for my $type ( keys %{ $self->model->wave->types } )
    {
        # Load user sprite if not defined
        unless( defined $self->sprite($type) )
        {
            $self->sprite($type => SDLx::Sprite::Animated->new(
                images          =>
                    config->param('unit'=>$type=>'animation'=>'right'),
                type            =>
                    config->param('unit'=>$type=>'animation'=>'type') ||
                    'circular',
                ticks_per_frame =>
                    int( $self->app->min_t * 1000 / 2 ),
            ));
            $self->sprite($type)->start;
        }
    }
}

sub _init_editor
{
    my ($self) = @_;

    $self->SUPER::_init_editor;

    for my $y (0 .. ($self->model->map->height - 1) )
    {
        for my $x (0 .. ($self->model->map->width - 1))
        {
            my $tail  = $self->model->map->tail($x,$y);
            my @path = keys(%{$tail->path || {}});

#            $self->font('editor_tail')->write_xy(
#                $self->sprite('map')->surface,
#                $x * $self->model->map->tail_width  + config->param('editor'=>'tail'=>'left'),
#                $y * $self->model->map->tail_height + config->param('editor'=>'tail'=>'top'),
#                sprintf("%s:%s%s", $x, $y, join(',', @path)),
#            );
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

    my $name = $type . $mod;

    # Load item tile if not defined
    unless( defined $self->sprite($name) )
    {
        $self->sprite($name => SDLx::Sprite->new(
            image => config->param('img'=>$type=>$mod=>'file'),
        ));
    }

    my $dx = int(
        ($self->sprite($name)->w - $self->model->map->tail_width)  / 2);
    my $dy = int(
        ($self->sprite($name)->h - $self->model->map->tail_height) / 2);

    $self->sprite($name)->rect(SDL::Rect->new(
        $self->model->map->tail_width  * $x - $dx,
        $self->model->map->tail_height * $y - $dy,
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
    # Draw map
    $self->sprite('map')->clip($self->model->camera->clip);
    $self->sprite('map')->rect($self->model->camera->rect);
    $self->sprite('map')->draw( $self->app );

    # Draw health counter
    $self->font('health')->write_xy(
        $self->app,
        $self->dest('health')->x,
        $self->dest('health')->y,
        sprintf '%s %s',
            config->param($self->conf=>'health'=>'text') || '',
            $self->model->health,
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

    # Draw sleep in center of screen
    if( $self->model->left )
    {
        my $text = int($self->model->left / 1000);
        $text = 'Go!' if $text < 1;

        $self->font('sleep')->text($text);
        $self->font('sleep')->write_xy(
            $self->app,
            int($self->dest('sleep')->x - $self->font('sleep')->w/2),
            int($self->dest('sleep')->y - $self->font('sleep')->h/2),
            $text
        );

        return;
    }

    # Draw active units
    my $units = $self->model->wave->active;
    for my $unit ( @$units )
    {
#        TODO: Need randomize start farme for new units
#        # Randomize start frame
#        $self->sprite('unit')->next
#            for 0 .. rand scalar @{ $unit{animation}{right} };

        $self->sprite($unit->type)->x( $unit->x - $self->model->camera->x );
        $self->sprite($unit->type)->y( $unit->y - $self->model->camera->y );
        $self->sprite($unit->type)->draw( $self->app );

        $self->font('editor_tail')->write_xy(
            $self->app,
            $unit->x - $self->model->camera->x,
            $unit->y - $self->model->camera->y,
            sprintf('%s %s:%s', $unit->direction || 'die', $unit->x, $unit->y),
        ) if config->param('editor'=>'enable');
    }
}

1;