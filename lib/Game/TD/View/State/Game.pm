use strict;
use warnings;
use utf8;

package Game::TD::View::State::Game;
use base qw(Game::TD::View);

use Carp;
use SDL;
use SDL::Rect;
use SDLx::Sprite;
#use SDLx::Sprite::Animated;
use SDLx::Sprite::Splited;
use SDLx::Text;

use SDL::GFX::Rotozoom;
use SDL::GFX::Primitives;

use Game::TD::Config;

=head1 NAME

Game::TD::View::State::Game

=cut

=head1 METHODS

=cut

=head2 new HASH

Конструктор

=head3 Входные параметры

=head4 параметр

=cut

sub new
{
    my ($class, %opts) = @_;

    die 'Missing required param "cursor"' unless defined $opts{cursor};

    my $self = $class->SUPER::new(%opts);

    $self->_init_viewport;
    $self->_init_background;
    $self->_init_sleep;
    $self->_init_map;
    $self->_init_items;
    $self->_init_units;
    $self->_init_panel;
    $self->_init_towers;
    $self->_init_cursor;

    $self->_init_editor if config->param('editor'=>'enable');

    return $self;
}

=head2 prepare

Prepare parts on viewport and panel

=cut

sub prepare
{
    my ($self) = @_;

    # Draw map
    $self->_draw_map;

    # Draw units on viewport
    $self->_draw_units;

    # Draw items
    $self->_draw_items;

    # Draw cursor if exists
    $self->_draw_cursor;

    # Draw text and buttons on panel
    $self->_draw_panel if $self->panel->visible;

    # Draw helpers text
    $self->_draw_editor if config->param('editor'=>'enable');

    # Draw sleep in center of viewport
    $self->_draw_sleep if $self->model->left;

    return 1;
}

=head2 draw

Draw all on App surface

=cut

sub draw
{
    my ($self) = @_;

    # Draw background
    # Not need if panel and viewport take all of screen
#    $self->sprite('background')->draw( $self->app );
    # Draw viewport
    $self->sprite('viewport')->draw($self->app);
    # Draw panel
    $self->sprite('panel')->draw($self->app) if $self->panel->visible;

    return 1;
}

sub panel   { return shift->{panel}     }
sub cursor  { return shift->{cursor}    }

=head1 PRIVATE INITIALIZATION METHODS

=cut

sub _init_background
{
    my ($self) = @_;

    # Clear background
    $self->app->draw_rect(
        SDL::Rect->new(0,0,$self->app->w, $self->app->h),
        0x000000FF
    );
    # Not need if panel and viewport take all of screen
#    $self->SUPER::_init_background;

}

sub _init_viewport
{
    my ($self) = @_;

    $self->sprite('viewport' => SDLx::Sprite->new(
#        clip    => $self->model->camera->clip,
        rect    => $self->model->camera->rect,
        width   => $self->model->camera->clip->w,
        height  => $self->model->camera->clip->h,
    ));
    SDL::Video::set_alpha($self->sprite('viewport')->surface, 0, 0);

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
            my $name = $tile->type . $tile->mod;

            $self->_draw_object(
                $self->sprite('map')->surface,
                $x,
                $y,
                $self->sprite($name),
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

    # Draw flat items on map
    for my $y (0 .. ($self->model->map->height - 1) )
    {
        for my $x (0 .. ($self->model->map->width - 1))
        {
            # Get item and draw it if exists
            my $tile  = $self->model->map->tile($x,$y);
            next unless $tile->has_item;
            next if $tile->item_type ne 'flat';

            my $name = $tile->item_type . $tile->item_mod;

            $self->_draw_object(
                $self->sprite('map')->surface,
                $x,
                $y,
                $self->sprite($name),
            );
        }
    }
}

sub _init_units
{
    my ($self) = @_;

    # Load sufraces for each unit type
#    for my $type ( keys %{ $self->model->wave->types } )
#    {
#        my $count = scalar
#            @{config->param('unit'=>$type=>'animation'=>'sequences'=>'right') };
#
#        # Load unit sprite if not defined
#        unless( defined $self->sprite($type) )
#        {
#            $self->sprite($type => SDLx::Sprite::Splited->new(
#                image          =>
#                    config->param('unit'=>$type=>'animation'=>'sequences'),
#                type            =>
#                    config->param('unit'=>$type=>'animation'=>'type') ||
#                    'circular',
#                ticks_per_frame =>
#                    config->param('common'=>'fps'=>'value') / $count,
#            ));
#        }
#    }

    # Create animation for each unit
    for my $path ($self->model->wave->names)
    {
        for my $unit (@{ $self->model->wave->path($path) })
        {
            my $image =
                config->param('unit'=>$unit->type=>'animation'=>'sequences');

            # Set transforms
            my $transform =
                config->param('unit'=>$unit->type=>'animation'=>'transform');

            for my $sub ( values %$transform )
            {
                next if 'HASH' ne ref $sub;

                if ($sub->{transform} eq 'mirror' or
                    $sub->{transform} eq 'rotate')
                {
                    my %data = (
                        angle   => $sub->{angle}       || 0,
                        x       => $sub->{x}           || 1,
                        y       => $sub->{y}           || 1,
                        flag    => $sub->{flag}        || SMOOTHING_OFF,
                    );

                    $sub = sub
                    {
                        my $surface = shift;

                        my $rotated = SDL::GFX::Rotozoom::surface_xy(
                            $surface->surface,
                            $data{angle},
                            $data{x},
                            $data{y},
                            $data{flag});
                        return SDLx::Surface->new(surface => $rotated);
                    };
                }
            }

            # Count total frames
            my $count = scalar @{$image->{right}};

            $self->sprite($unit->id => SDLx::Sprite::Splited->new(
                image           => $image,
                transform       => $transform,
                type            =>
                    config->param('unit'=>$unit->type=>'animation'=>'type') ||
                    'circular',
                ticks_per_frame =>
                    config->param('common'=>'fps'=>'value') / $count,
                sequence        =>
                    $unit->direction,
            ));

#            $self->sprite($name => SDLx::Sprite::Splited->new(
#                surface         => $self->sprite($unit->type)->surface,
#                type            => $self->sprite($unit->type)->type,
#                ticks_per_frame => $self->sprite($unit->type)->ticks_per_frame,
#                step_x          => $self->sprite($unit->type)->step_x,
#                step_y          => $self->sprite($unit->type)->step_y,
#                width           => $self->sprite($unit->type)->clip->w,
#                height          => $self->sprite($unit->type)->clip->h,
#            ));
            # Randomize start frame
            $self->sprite($unit->id)->next for 0 .. $count;
            # Run animation
            $self->sprite($unit->id)->start;
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
        color   => config->param($self->conf=>'sleep'=>'color'),
        mode    => 'utf8',
        text    => int($self->model->left / 1000),
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
            my @path = map s/\D//g, keys(%{$tile->path || {}});

            $self->font('editor_tile')->write_xy(
                $self->sprite('map')->surface,
                $x * $self->model->map->tile_width,
                $y * $self->model->map->tile_height,
                sprintf("%s:%s%s",
                    $x, $y,
                    (@path) ? ' ['.join(',', @path).']' :''
                ),
            );

            if($tile->has_item)
            {
                $self->font('editor_tile')->write_xy(
                    $self->sprite('map')->surface,
                    $x * $self->model->map->tile_width,
                    $self->font('editor_tile')->size + 2 + $y * $self->model->map->tile_height,
                    $tile->item_type
                );

                $self->font('editor_tile')->write_xy(
                    $self->sprite('map')->surface,
                    $x * $self->model->map->tile_width,
                    ($self->font('editor_tile')->size + 2) * 2 + $y * $self->model->map->tile_height,
                    $tile->item_mod
                );
            }
        }
    }
}

sub _init_panel
{
    my ($self) = @_;


    $self->sprite('panel' => SDLx::Sprite->new(
        surface => SDLx::Surface->new(
            width   => $self->panel->rect->w,
            height  => $self->panel->rect->h,
            flags   => SDL_HWSURFACE,
        ),
        rect    => $self->panel->rect,
    ));
    SDL::Video::set_alpha($self->sprite('panel')->surface, 0, 0);
#    $self->sprite('panel')->surface->draw_rect(
#        SDL::Rect->new(0,0,$self->sprite('panel')->w,$self->sprite('panel')->h),
#        0xFF0000FF
#    );

    $self->sprite('panel_background' => SDLx::Sprite->new(
        image   => config->param($self->conf=>'panel'=>'file'),
        clip    => $self->sprite('panel')->clip,
    ));
    $self->sprite('panel_background')->draw($self->sprite('panel')->surface);

    # Level title font
    $self->font(title => SDLx::Text->new(
        font    => config->param($self->conf=>'title'=>'font'),
        size    => config->param($self->conf=>'title'=>'size'),
        color   => config->param($self->conf=>'title'=>'color'),
        mode    => 'utf8',
        text    => $self->model->title,
    ));
    $self->dest(title => SDL::Rect->new(
        config->param($self->conf=>'title'=>'fleft'),
        config->param($self->conf=>'title'=>'ftop'),
        $self->font('title')->w,
        $self->font('title')->h,
    ));

    # Health counter font
    $self->font(health => SDLx::Text->new(
        font    => config->param($self->conf=>'health'=>'font'),
        size    => config->param($self->conf=>'health'=>'size'),
        color   => config->param($self->conf=>'health'=>'color'),
        mode    => 'utf8',
        text    => $self->model->health,
    ));
    $self->dest(health => SDL::Rect->new(
        config->param($self->conf=>'health'=>'fleft'),
        config->param($self->conf=>'health'=>'ftop'),
        0 ,0
    ));

    # Money font
    $self->font(money => SDLx::Text->new(
        font    => config->param($self->conf=>'money'=>'font'),
        size    => config->param($self->conf=>'money'=>'size'),
        color   => config->param($self->conf=>'money'=>'color'),
        mode    => 'utf8',
        text    => $self->model->player->money,
    ));
    $self->dest(money => SDL::Rect->new(
        config->param($self->conf=>'money'=>'fleft'),
        config->param($self->conf=>'money'=>'ftop'),
        0 ,0
    ));
}

sub _init_towers
{
    my ($self) = @_;

    for my $name ( $self->model->force->types )
    {
        $self->sprite($name => SDLx::Sprite->new(
            image => config->param('tower'=>'towers'=>$name=>'item'=>'file'),
        ));
    }
}

sub _init_cursor
{
    my ($self) = @_;

    $self->color('cursor_fill' =>
        config->param('game'=>'cursor'=>'range'=>'fill'=>'color'));
    $self->color('cursor_circle' =>
        config->param('game'=>'cursor'=>'range'=>'circle'=>'color'));
}

=head1 PRIVATE COMMON DRAW METHODS

=cut

sub _draw_object
{
    my ($self, $surface, $x, $y, $sprite) = @_;

    croak 'Missing required parameter "surface"'    unless defined $surface;
    croak 'Missing required parameter "sprite"'     unless defined $sprite;
    croak 'Missing required parameter "x"'          unless defined $x;
    croak 'Missing required parameter "y"'          unless defined $y;

    # Always draw center of object on center of tile
    my $dx = int(
        ($sprite->w - $self->model->map->tile_width)  / 2);
    my $dy = int(
        ($sprite->h - $self->model->map->tile_height) / 2);

    $sprite->rect(SDL::Rect->new(
        $self->model->map->tile_width  * $x - $dx - $self->model->camera->x,
        $self->model->map->tile_height * $y - $dy - $self->model->camera->y,
        $sprite->w,
        $sprite->h
    ));

    # Apply item tile to background
    $sprite->draw( $surface );

    return;
}

=head1 PRIVATE DRAW METHODS

=cut

sub _draw_map
{
    my ($self) = @_;

    $self->sprite('map')->clip($self->model->camera->clip);
    $self->sprite('map')->draw( $self->sprite('viewport')->surface );
}

sub _draw_units
{
    my ($self) = @_;

    my $active = $self->model->wave->active;
    # Draw active units
    for my $unit ( @$active )
    {
        my $dx = int(
            ( $self->sprite($unit->id)->clip->w - $self->model->map->tile_width)  / 2);
        my $dy = int(
            ( $self->sprite($unit->id)->clip->h - $self->model->map->tile_height) / 2);

        $self->sprite($unit->id)->sequence($unit->direction) if
            $unit->direction and
            $self->sprite($unit->id)->sequence ne $unit->direction;
        $self->sprite($unit->id)->x( $unit->x - $dx - $self->model->camera->x );
        $self->sprite($unit->id)->y( $unit->y - $dy - $self->model->camera->y );
        $self->sprite($unit->id)->draw( $self->sprite('viewport')->surface );
    }

    return 1;
}

sub _draw_panel
{
    my ($self) = @_;

    $self->sprite('panel_background')->draw($self->sprite('panel')->surface);


#    $self->sprite('panel_background')->clip($self->dest('title'));
#    $self->sprite('panel_background')->draw($self->sprite('panel')->surface);
    # Draw title on panel
    $self->font('title')->write_xy(
        $self->sprite('panel')->surface,
        $self->dest('title')->x,
        $self->dest('title')->y,
    );

    # Draw health counter
    my $health = sprintf '%s %s',
        config->param($self->conf=>'health'=>'text') || '',
        $self->model->health;
    $self->font('health')->text($health)
        if $health ne $self->font('health')->text;
    $self->font('health')->write_xy(
        $self->sprite('panel')->surface,
        $self->dest('health')->x,
        $self->dest('health')->y,
    );

    # Draw money
    my $money = sprintf '%s %s',
            config->param($self->conf=>'money'=>'text') || '',
            $self->model->player->money;
    $self->font('money')->text($money)
        if $money ne $self->font('money')->text;
    $self->font('money')->write_xy(
        $self->sprite('panel')->surface,
        $self->dest('money')->x,
        $self->dest('money')->y,
    );

    return 1;
}

sub _draw_cursor
{
    my ($self) = @_;

    return 1 if $self->cursor->state eq 'default';
    return 1 if $self->cursor->state eq 'impossible';

    # Get screen coordinater to draw range
    my $x = $self->model->map->tile_width  * $self->cursor->x +
            int($self->model->map->tile_width  / 2) -
            $self->model->camera->x;
    my $y = $self->model->map->tile_height * $self->cursor->y +
            int($self->model->map->tile_height / 2) -
            $self->model->camera->y;
    # Draw tower range
    SDL::GFX::Primitives::filled_circle_color(
        $self->sprite('viewport')->surface,
        $x, $y,
        $self->model->force->attr($self->cursor->state, 'range'),
        $self->color('cursor_fill') );
    SDL::GFX::Primitives::aacircle_color(
        $self->sprite('viewport')->surface,
        $x, $y,
        $self->model->force->attr($self->cursor->state, 'range'),
        $self->color('cursor_circle') );

    # Draw tower sprite
    $self->_draw_object(
        $self->sprite('viewport')->surface,
        $self->cursor->x,
        $self->cursor->y,
        $self->sprite($self->cursor->state),
    );

    return 1;
}

sub _draw_sleep
{
    my ($self) = @_;

    my $text = int($self->model->left / 1000);
    $text = 'Go!' if $text < 1;

    $self->font('sleep')->text($text) if $text ne $self->font('sleep')->text;
    $self->font('sleep')->write_xy(
        $self->sprite('viewport')->surface,
        $self->dest('sleep')->x - int($self->font('sleep')->w/2),
        $self->dest('sleep')->y - int($self->font('sleep')->h/2),
        $text
    );

    return 1;
}

sub _draw_editor
{
    my ($self) = @_;

    my $active = $self->model->wave->active;
    # Draw active units info text
    for my $unit ( @$active )
    {
        my $dx = int(
            ( $self->sprite($unit->id)->clip->w - $self->model->map->tile_width)  / 2);
        my $dy = int(
            ( $self->sprite($unit->id)->clip->h - $self->model->map->tile_height) / 2);

        $self->font('editor_tile')->write_xy(
            $self->sprite('viewport')->surface,
            $unit->x - $dx - $self->model->camera->x,
            $unit->y - $dy - $self->model->camera->y,
            sprintf('%s %s:%s', $unit->direction || 'die', $unit->x, $unit->y),
        );
    }

    # Draw cursor logical coordinates
    $self->font('editor_cursor')->write_xy(
        $self->sprite('viewport')->surface,
        $self->cursor->x * $self->model->map->tile_width  - $self->model->camera->x,
        $self->cursor->y * $self->model->map->tile_height - $self->model->camera->y,
        sprintf('%s:%s', $self->cursor->x, $self->cursor->y),
    );

    for my $tower ($self->model->force->active)
    {
        $self->font('editor_tower')->write_xy(
            $self->sprite('viewport')->surface,
            $tower->tile->x - $self->model->camera->x,
            $tower->tile->y - $self->model->camera->y + $self->font('editor_tile')->h,
            ($tower->prepare) ?sprintf('%d',$tower->prepare) :'ready',
        );
    }
}

sub _draw_items
{
    my ($self) = @_;

    for my $y (0 .. ($self->model->map->height - 1) )
    {
        for my $x (0 .. ($self->model->map->width - 1))
        {
            # Get item and draw it if exists
            my $tile  = $self->model->map->tile($x,$y);
            # Skip if item not exists
            next unless $tile->has_item;
            # Flat item already drawed on map in init function
            next if $tile->item_type eq 'flat';

            my $name = 'unknown';
            if($tile->item_type eq 'tower')
            {
                $name = $tile->item_mod;
            }
            else
            {
                $name = $tile->item_type . $tile->item_mod;
            }

            $self->_draw_object(
                $self->sprite('viewport')->surface,
                $x,
                $y,
                $self->sprite($name),
            );
        }
    }
}
1;
