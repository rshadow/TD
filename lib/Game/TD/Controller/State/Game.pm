use strict;
use warnings;
use utf8;

package Game::TD::Controller::State::Game;
use base qw(Game::TD::Controller);

use Carp;
use SDL::Event;

use Game::TD::Config;
use Game::TD::Notify;
use Game::TD::Model::State::Game;
use Game::TD::Model::Panel;
use Game::TD::Model::Cursor;
use Game::TD::View::State::Game;

=head1 NAME

Game::TD::Controller::State::Game - Модуль

=head1 SYNOPSIS

  use Game::TD::Controller::State::Game;

=head1 DESCRIPTION

=cut

=head1 METHODS

=cut

sub new
{
    my ($class, %opts) = @_;

    die 'Missing required param "app"'      unless defined $opts{app};
    die 'Missing required param "player"'   unless defined $opts{player};
    die 'Missing required param "level"'    unless defined $opts{level};

    $opts{pause} //= 0;

    my $self = $class->SUPER::new(%opts);

    $self->model( Game::TD::Model::State::Game->new(
        num     => $opts{level},
        player  => $self->player,
        dt      => $self->app->dt,
    ));

    $self->panel( Game::TD::Model::Panel->new(
        visible => 1
    ));

    # Get current mouse position on map
    my ($mask,$x,$y) = @{ SDL::Events::get_mouse_state( ) };
    my ($map_x, $map_y) = $self->model->camera->xy2map($x, $y);
    # Create cursor
    $self->cursor( Game::TD::Model::Cursor->new(
#        app     => $self->app,
        x => $map_x,
        y => $map_y,
    ));

    $self->view( Game::TD::View::State::Game->new(
        app     => $self->app,
        model   => $self->model,
        panel   => $self->panel,
        cursor  => $self->cursor,
    ));

    # Set buttons on panel
    for my $name ('menu', 'pause', $self->model->force->types)
    {
        $self->button(
            $name,
            $self->conf,
            $self->view->sprite('panel')->surface,
            prect => $self->view->sprite('panel')->rect
        );
    }
    # Update buttons state
    $self->_update_buttons;

    return $self;
}

sub update
{
    my ($self, $step, $t) = @_;

    my %result;

    return \%result if $self->is_pause;

    my $process = $self->model->update($step, $t);

    unless( $process )
    {
        notify('Level "%s" is %s',
            $self->model->title, $self->model->result('finish'));
        $result{state} = 'score';
    }

    $self->_update_buttons;

    return \%result;
}

sub event
{
    my ($self, $event) = @_;

    my %result;
    my $type = $event->type;

    if($type == SDL_MOUSEMOTION)
    {
        # Get mouse position and screen params
        my $x       = $event->motion_x;
        my $y       = $event->motion_y;
        my $width   = $self->app->surface->w;
        my $height  = $self->app->surface->h;
        # Sensetive border
        my $border  = $self->model->camera->border;

        # Scroll camera on mouse
        ($x <= $border)
            ? $self->model->camera->move('left')
            : $self->model->camera->stop('left');
        ($x >= ($width-$border))
            ? $self->model->camera->move('right')
            : $self->model->camera->stop('right');
        ($y <= $border)
            ? $self->model->camera->move('up')
            : $self->model->camera->stop('up');
        ($y >= ($height-$border))
            ? $self->model->camera->move('down')
            : $self->model->camera->stop('down');


        # If mouse move in camera
        if( $self->model->camera->is_over($x, $y) )
        {
            # Update cursor coords
            my ($map_x, $map_y) = $self->model->camera->xy2map($x, $y);
            $self->cursor->x($map_x);
            $self->cursor->y($map_y);

            # Set cursor as bad place if can`t build on this tile
            if( $self->model->map->tile($map_x, $map_y)->has_item )
            {
                $self->cursor->state('impossible');
            }
            # Set cursor as tower
            else
            {
                $self->cursor->state( 'default' );
                $self->cursor->state( $self->cursor->tower );
            }
        }
        else
        {
            # when cursor leave viewport temporarily drop state
            $self->cursor->state('default');
        }

    }
    elsif($type == SDL_KEYDOWN)
    {
        my $sym = $event->key_sym;

        if($sym == SDLK_PAUSE    || $sym == SDLK_p)
        {
            $self->pause;
        }
        elsif($sym == SDLK_UP    || $sym == SDLK_w)
        {
            $self->model->camera->move('up');
        }
        elsif($sym == SDLK_LEFT  || $sym == SDLK_a)
        {
            $self->model->camera->move('left');
        }
        elsif($sym == SDLK_DOWN  || $sym == SDLK_s)
        {
            $self->model->camera->move('down');
        }
        elsif($sym == SDLK_RIGHT || $sym == SDLK_d)
        {
            $self->model->camera->move('right');
        }
    }
    elsif($type == SDL_KEYUP)
    {
        my $sym = $event->key_sym;

        if($sym == SDLK_UP    || $sym == SDLK_w)
        {
            $self->model->camera->stop('up');
        }
        elsif($sym == SDLK_LEFT  || $sym == SDLK_a)
        {
            $self->model->camera->stop('left');
        }
        elsif($sym == SDLK_DOWN  || $sym == SDLK_s)
        {
            $self->model->camera->stop('down');
        }
        elsif($sym == SDLK_RIGHT || $sym == SDLK_d)
        {
            $self->model->camera->stop('right');
        }
    }
    elsif($type == SDL_MOUSEBUTTONDOWN)
    {
        # Get mouse button
        my $button  = $event->button_button;

        # Mouse wheel
        if( $button == SDL_BUTTON_WHEELUP )
        {
            $self->model->camera->move('up');
            # Force one step update
            $self->model->camera->update;
        }
        elsif( $button == SDL_BUTTON_WHEELDOWN )
        {
            $self->model->camera->move('down');
            # Force one step update
            $self->model->camera->update;
        }
        elsif( $button == SDL_BUTTON_X1 )
        {
            $self->model->camera->move('left');
            # Force one step update
            $self->model->camera->update;
        }
        elsif( $button == SDL_BUTTON_X2 )
        {
            $self->model->camera->move('right');
            # Force one step update
            $self->model->camera->update;
        }
    }
    elsif($type == SDL_MOUSEBUTTONUP)
    {
        # Get mouse position and screen params
        my $x       = $event->motion_x;
        my $y       = $event->motion_y;
        # Get mouse button
        my $button  = $event->button_button;
        # Get keyboard mod
        my $mod     = SDL::Events::get_mod_state();

        if( $button == SDL_BUTTON_LEFT )
        {
            # Build tower if mouse move in camera and not on some item
            if( $self->model->camera->is_over($x, $y) and
                $self->cursor->state ne 'impossible'  and
                $self->cursor->state ne 'default' )
            {
                # Get map coords under cursor
                my ($map_x, $map_y) = $self->model->camera->xy2map($x, $y);
                # Add tower to map
                my $tower = $self->model->force->build(
                    $self->cursor->tower,
                    $self->model->map->tile($map_x, $map_y)
                );

                # Subtract money
                $self->player->money($self->player->money - $tower->cost);

                # Update buttons state
                $self->_update_buttons;

                # Drop cursor state and tower if not in multi mode or
                # not enough money
                if(!($mod & KMOD_CTRL) or $self->player->money < $tower->cost)
                {
                    $self->cursor->tower('default');
                    $self->cursor->state('default');
                }
            }

        }
        elsif( $button == SDL_BUTTON_RIGHT )
        {
            # Just drop cursor state and tower
            $self->cursor->tower('default');
            $self->cursor->state('default');
        }
        # Mouse wheel
        elsif( $button == SDL_BUTTON_WHEELUP )
        {
            $self->model->camera->stop('up');
        }
        elsif( $button == SDL_BUTTON_WHEELDOWN )
        {
            $self->model->camera->stop('down');
        }
        elsif( $button == SDL_BUTTON_X1 )
        {
            $self->model->camera->stop('left');
        }
        elsif( $button == SDL_BUTTON_X2 )
        {
            $self->model->camera->stop('rigth');
        }

    }

    # If panel visible then send event for panel buttons
    if( $self->panel->visible )
    {
        if( $self->button('menu')->event_handler( $event ) eq 'up' )
        {
            $result{state} = 'menu';
        }

        if( $self->button('pause')->event_handler( $event ) eq 'up' )
        {
            $self->pause;
        }

        for my $name ( $self->model->force->types )
        {
            if( $self->button($name)->event_handler( $event ) eq 'up' )
            {
                $self->cursor->tower($name);
                $self->cursor->state($name);
            }
        }
    }

    return \%result;
}

sub draw
{
    my $self = shift;

    # Prepare to draw
    $self->view->prepare unless $self->is_pause;

    if( $self->panel->visible )
    {
        $self->button('menu')->draw_handler;
        $self->button('pause')->draw_handler;

        unless( $self->is_pause )
        {
            $self->button($_)->draw_handler for $self->model->force->types;

#            print "##########################################\n";
#            printf "%s - %s\n", 'fireball', Dumper $self->button('fireball');
        }
    }

    # Draw
    $self->view->draw unless $self->is_pause;

    return 1;
}

=head2 player

Return player object

=cut

sub player
{
    return shift()->{player};
}

=head2 panel $value

Set panel object if set $value or return if $value not set.

=cut

sub panel
{
    my ($self, $panel) = @_;

    $self->{panel} = $panel  if defined $panel;
    return $self->{panel};
}

=head2 cursor $cursor

Set cursor object if set $cursor or return if $cursor not set.

=cut

sub cursor
{
    my ($self, $cursor) = @_;

    $self->{cursor} = $cursor  if defined $cursor;
    return $self->{cursor};
}

=head2 is_pause

Return true if game paused

=cut

sub is_pause
{
    my $self = shift;
    return $self->{pause};
}

=head2 pause

Toggle game pause

=cut

sub pause
{
    my $self = shift;
    $self->{pause} = not $self->{pause};

    # TODO: Pause timers

    return $self->{pause};
}

sub _update_buttons
{
    my ($self) = @_;

    for my $type ( $self->model->force->types )
    {
        if( $self->button($type)->disable )
        {
            # Disable button if tower too expensive
            $self->button($type)->disable(0)
                    if $self->player->money >=
                       $self->model->force->attr($type => 'cost');
        }
        else
        {
            # Disable button if tower too expensive
            $self->button($type)->disable(1)
                    if $self->player->money <
                       $self->model->force->attr($type => 'cost');
        }
    }
}
1;