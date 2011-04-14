use strict;
use warnings;
use utf8;

package Game::TD::View::State::Game;
use base qw(Game::TD::View);

use Carp;
use SDL;
use SDL::Rect;
use SDLx::Sprite;
use SDLx::Sprite::Animated;
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

    $self->_init_viewport;
    $self->_init_background;
    $self->_init_sleep;
    $self->_init_map;
    $self->_init_items;
    $self->_init_units;
    $self->_init_panel;
    $self->_init_towers;

    $self->_init_editor if config->param('editor'=>'enable');

    return $self;
}

#sub _init_background
#{
#    my ($self) = @_;
#    $self->SUPER::_init_background;
#
#}

sub _init_viewport
{
    my ($self) = @_;

    $self->sprite('viewport' => SDLx::Sprite->new(
#        clip    => $self->model->camera->clip,
        rect    => $self->model->camera->rect,
        width   => $self->model->camera->clip->w,
        height  => $self->model->camera->clip->h,
    ));

    $self->sprite('viewport')->surface->draw_rect(
        $self->model->camera->clip,
        0xFF00FFFF
    );
}

sub _init_map
{
    my ($self) = @_;

    $self->sprite('map' => SDLx::Sprite->new(
        clip    => $self->model->camera->clip,
#        rect    => $self->model->camera->rect,
        width   => $self->model->map->tile_map_width,
        height  => $self->model->map->tile_map_height,
    ));

    # Init map by filling color
    $self->sprite('map')->surface->draw_rect(
        SDL::Rect->new(
            0, 0,
            $self->model->map->tile_map_width,
            $self->model->map->tile_map_height),
        0xFFFF00FF
    );

    # Get types of tiles on this map
    my %types = $self->model->map->tile_types;
    # Load sprites for all this types
    for my $type (keys %types)
    {
        for my $mod (keys %{$types{$type}})
        {
            my $name = $type.$mod;

            $self->sprite($name => SDLx::Sprite->new(
                image => config->param('map'=>$type=>$mod=>'file'),
            ));
        }
    }

    # Draw tiles on map
    for my $y (0 .. ($self->model->map->height - 1) )
    {
        for my $x (0 .. ($self->model->map->width - 1))
        {
            my $tile = $self->model->map->tile($x,$y);

            $self->_draw_type(
                $self->sprite('map')->surface,
                $x,
                $y,
                $tile->type,
                $tile->mod,
            );
        }
    }
}

sub _init_items
{
    my ($self) = @_;

    # Get items of tiles on this map
    my %types = $self->model->map->item_types;
    # Load sprites for all this types
    for my $type (keys %types)
    {
        for my $mod (keys %{$types{$type}})
        {
            my $name = $type.$mod;

            $self->sprite($name => SDLx::Sprite->new(
                image => config->param('map'=>$type=>$mod=>'file'),
            ));
        }
    }

    # Draw items on map
    for my $y (0 .. ($self->model->map->height - 1) )
    {
        for my $x (0 .. ($self->model->map->width - 1))
        {
            # Get item and draw it if exists
            my $tile  = $self->model->map->tile($x,$y);
            next unless $tile->has_item;

            $self->_draw_type(
                $self->sprite('map')->surface,
                $x,
                $y,
                $tile->item_type,
                $tile->item_mod,
            );
        }
    }
}

sub _init_units
{
    my ($self) = @_;

    # Load sufraces for each unit type
    for my $type ( keys %{ $self->model->wave->types } )
    {
        # Load unit sprite if not defined
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
        }
    }

    # Create animation for each unit
    for my $path ($self->model->wave->names)
    {
        for my $unit (@{ $self->model->wave->path($path) })
        {
            my $name = $unit->type . $unit->index;

            $self->sprite($name => SDLx::Sprite::Animated->new(
                surface         => $self->sprite($unit->type)->surface,
                type            => $self->sprite($unit->type)->type,
                ticks_per_frame => $self->sprite($unit->type)->ticks_per_frame,
                step_x          => $self->sprite($unit->type)->step_x,
                step_y          => $self->sprite($unit->type)->step_y,
                width           => $self->sprite($unit->type)->clip->w,
                height          => $self->sprite($unit->type)->clip->h,
            ));
            # Randomize start frame
            $self->sprite($name)->next
                for 0 .. rand scalar @{ config->param('unit'=>$unit->type=>'animation'=>'right') };
            # Run animation
            $self->sprite($name)->start;
        }
    }
}

sub _init_sleep
{
    my ($self) = @_;

    # Sleep font
    $self->font(sleep => SDLx::Text->new(
        font    => config->param($self->conf=>'sleep'=>'font'),
        size    => config->param($self->conf=>'sleep'=>'size'),
        color   => config->color($self->conf=>'sleep'=>'color'),
        mode    => 'utf8',
    ));
    $self->dest(sleep => SDL::Rect->new(
        $self->model->camera->left + int($self->model->camera->w / 2),
        $self->model->camera->top  + int($self->model->camera->h / 2),
        0 ,0
    ));
}

sub _init_editor
{
    my ($self) = @_;

    $self->SUPER::_init_editor;

    for my $y (0 .. ($self->model->map->height - 1) )
    {
        for my $x (0 .. ($self->model->map->width - 1))
        {
            my $tile  = $self->model->map->tile($x,$y);
            my @path = map {$_=~s/\D//g; $_} keys(%{$tile->path || {}});

            $self->font('editor_tile')->write_xy(
                $self->sprite('map')->surface,
                $x * $self->model->map->tile_width,
                $y * $self->model->map->tile_height,
                sprintf("%s:%s%s",
                    $x, $y,
                    (@path) ? ' ['.join(',', @path).']' :''
                ),
            );
        }
    }
}

sub _init_panel
{
    my ($self) = @_;

    $self->sprite('panel' => SDLx::Sprite->new(
        surface => SDLx::Surface->new(
            width   => config->param($self->conf=>'panel'=>'width'),
            height  => config->param($self->conf=>'panel'=>'height'),
        ),
        rect    => SDL::Rect->new(
            config->param('common'=>'window'=>'width') -
                config->param($self->conf=>'panel'=>'width'),
            config->param('common'=>'window'=>'height') -
                config->param($self->conf=>'panel'=>'height'),
            config->param($self->conf=>'panel'=>'width'),
            config->param($self->conf=>'panel'=>'height')),
    ));
    $self->sprite('panel')->surface->draw_rect(
        SDL::Rect->new(
            0, 0,
            $self->sprite('panel')->w,
            $self->sprite('panel')->h),
        0xFF0000FF
    );

    $self->sprite('panel_background' => SDLx::Sprite->new(
        image   => config->param($self->conf=>'panel'=>'file'),
        clip    => $self->sprite('panel')->clip,
    ));

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
}

sub _init_towers
{
    my ($self) = @_;

#    my @names = keys %{ config->param('tower') };
#    die Dumper @names;
}

sub _draw_type
{
    my ($self, $surface, $x, $y, $type, $mod) = @_;

    croak 'Missing required parameter "surface"'    unless defined $surface;
    croak 'Missing required parameter "type"'       unless defined $type;
    croak 'Missing required parameter "mod"'        unless defined $mod;
    croak 'Missing required parameter "x"'          unless defined $x;
    croak 'Missing required parameter "y"'          unless defined $y;

    my $name = $type . $mod;

    my $dx = int(
        ($self->sprite($name)->w - $self->model->map->tile_width)  / 2);
    my $dy = int(
        ($self->sprite($name)->h - $self->model->map->tile_height) / 2);

    $self->sprite($name)->rect(SDL::Rect->new(
        $self->model->map->tile_width  * $x - $dx - $self->model->camera->x,
        $self->model->map->tile_height * $y - $dy - $self->model->camera->y,
        $self->sprite($name)->w,
        $self->sprite($name)->h
    ));

    # Apply item tile to background
    $self->sprite($name)->draw( $surface );

    return;
}

=head2 draw

Draw intro

=cut

sub prepare
{
    my ($self) = @_;

    # Draw map on viewport
    $self->sprite('map')->clip($self->model->camera->clip);
    $self->sprite('map')->draw( $self->sprite('viewport')->surface );

    # Draw units on viewport
    $self->_draw_units;

    # Draw sleep in center of viewport
    $self->_draw_sleep if $self->model->left;

    # Draw text and buttons on panel
    $self->_draw_panel;

    return 1;
}

sub draw
{
    my ($self) = @_;

    # Draw background
    $self->sprite('background')->draw( $self->app );
    # Draw viewport
    $self->sprite('viewport')->draw($self->app);
    # Draw panel
    $self->sprite('panel')->draw($self->app);

    return 1;
}

sub _draw_units
{
    my ($self) = @_;

    my $active = $self->model->wave->active;
    # Draw active units
    for my $unit ( @$active )
    {
        my $name = $unit->type . $unit->index;

        my $dx = int(
            ( $self->sprite($name)->clip->w - $self->model->map->tile_width)  / 2);
        my $dy = int(
            ( $self->sprite($name)->clip->h - $self->model->map->tile_height) / 2);

        $self->sprite($name)->x( $unit->x - $dx - $self->model->camera->x );
        $self->sprite($name)->y( $unit->y - $dy - $self->model->camera->y );
        $self->sprite($name)->draw( $self->sprite('viewport')->surface );

        $self->font('editor_tile')->write_xy(
            $self->sprite('viewport')->surface,
            $unit->x - $dx - $self->model->camera->x,
            $unit->y - $dy - $self->model->camera->y,
            sprintf('%s %s:%s', $unit->direction || 'die', $unit->x, $unit->y),
        ) if config->param('editor'=>'enable');
    }

    return 1;
}

sub _draw_panel
{
    my ($self) = @_;

    $self->sprite('panel_background')->draw($self->sprite('panel')->surface);

    # Draw title on panel
    $self->font('title')->write_xy(
        $self->sprite('panel')->surface,
        $self->dest('title')->x,
        $self->dest('title')->y,
        $self->model->title,
    );

    # Draw health counter
    $self->font('health')->write_xy(
        $self->sprite('panel')->surface,
        $self->dest('health')->x,
        $self->dest('health')->y,
        sprintf '%s %s',
            config->param($self->conf=>'health'=>'text') || '',
            $self->model->health,
    );

    # Draw score
    $self->font('score')->write_xy(
        $self->sprite('panel')->surface,
        $self->dest('score')->x,
        $self->dest('score')->y,
        sprintf '%s %s',
            config->param($self->conf=>'score'=>'text') || '',
            $self->model->player->score,
    );

    return 1;
}

sub _draw_sleep
{
    my ($self) = @_;

    my $text = int($self->model->left / 1000);
    $text = 'Go!' if $text < 1;

    $self->font('sleep')->text($text);
    $self->font('sleep')->write_xy(
        $self->sprite('viewport')->surface,
        $self->dest('sleep')->x - int($self->font('sleep')->w/2),
        $self->dest('sleep')->y - int($self->font('sleep')->h/2),
        $text
    );

    return 1;
}


1;