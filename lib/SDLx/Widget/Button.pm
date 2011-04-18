use strict;
use warnings;
use utf8;

package SDLx::Widget::Button;
use base qw(SDLx::Sprite::Animated);

use Carp;

use SDL;
use SDL::Event;
use SDL::Events;
use SDLx::App;
use SDLx::Text;

=head1 NAME

Game::TD::Model::Button - Simple rectangle button

=head1 SYNOPSIS

    use Game::TD::Model::Button;

    # Create application
    $app = SDLx::App->new;

    # Create button from image file.
    my $button = SDLx::Widget::Button->new(
        image       => 'button.png',
        step_x      => 1,
        step_y      => 1,
        sequences   => {
            over    => [[0,0]],
            out     => [[100,0]],
            down    => [[200,0]],
            up      => [[300,0]],
            d_over  => [[400,0]],
            d_out   => [[500,0]],
        },
        rect        => SDL::Rect->new(0,0,100,100),

        # Set application surface as parent
        parent      => $app,
        # Button disabled (by default button enabled)
        disable     => 1,

    );

    # Set button handlers
    $app->add_event_handler( sub{
        my ($event, $app) = @_;
        exit if $event->type eq SDL_QUIT;
        # Send events to button and react on left mouse button up
        if($button->event( $event ) eq 'up')
        {
            ...
        }
    });

    $app->add_show_handler( sub{
        # Draw button
        $button->draw;
        $app->flip;
    });

    # Run application
    $app->run;

=head1 DESCRIPTION

This is simple rectangle button to use in SDL application. SDLx::Widget::Button
based on SDLx::Sprite::Animated package and take all of it`s methods and
options.

You need to set named sequence for each button state for draw:
over - mouse corsor outside the button,
out  - mouse cirsor on button,
down - left "mouse button" pressed on button,
up   - left "mouse button" unpressed on button.
Sequence d_over and d_out is optional. If you want disable/enable button then
this sequences.

=cut

=head1 METHODS

=cut

=head2 new %opts

This constrictor take options from SDLx::Sprite::Animated, except:

=item parent

This is SDLx::App or SDLx::Surface to draw button on it.

=item disable

Flag to disable button. Disabled button has it`s own sequences for draw and not
react on mouse button click.

=back

=cut

sub new
{
    my ($class, %opts) = @_;

    my $parent  = delete $opts{parent};
    my $disable = delete $opts{disable} // 0;

    confess 'Need SDLx::App or SDLx::Surface as parent'
        unless defined $parent;

    my $self = $class->SUPER::new(%opts);

    $self->parent( $parent );
    $self->disable( $disable );

    $self->sequence( ($self->disable) ?'d_out' :'out' );

    return $self;
}

=head2 draw $event

Event handler. Update button sequence on user $event (SDL::Event object):
move mouse, click buttons.

=cut

sub event
{
    my ($self, $event) = @_;

    my $type        = $event->type;
    my $sequence    = $self->sequence;
    my $prev        = $sequence;

    if($type == SDL_MOUSEMOTION)
    {
        if( $self->is_over($event->motion_x, $event->motion_y) )
        {
            $sequence = 'over' unless $sequence eq 'down';
        }
        else
        {
            $sequence = 'out';
        }
    }
    elsif($type == SDL_MOUSEBUTTONDOWN && ! $self->disable)
    {
        if( $event->button_button == SDL_BUTTON_LEFT )
        {
            $sequence = 'down'
                if $self->is_over($event->button_x, $event->button_y);
        }
    }
    elsif($type == SDL_MOUSEBUTTONUP && ! $self->disable)
    {
        # Check 'down' for prevent press from another state
        if($sequence eq 'down')
        {
            if( $event->button_button == SDL_BUTTON_LEFT )
            {
                $sequence = 'up'
                    if $self->is_over($event->button_x, $event->button_y);
            }
        }
    }

    # Update sequence if state changed
    $self->sequence( ($self->disable) ?"d_$sequence" :$sequence )
        if $prev ne $sequence;

    return $sequence;
}

=head2 draw $surface

Draw button on $surface. By default $surface gets from parent.

=cut

sub draw
{
    my ($self, $surface) = @_;

    $self->SUPER::draw($surface // $self->parent);

    return 1;
}

=head2 is_over $x, $y

Check if $x and $y coordinates within button rect

=cut

sub is_over
{
    my ($self, $x, $y) = @_;

    my ($dx, $dy) = (0,0);#($self->parent->x, $self->parent->y);

    return 1 if
        $x >= $dx + $self->rect->x                  &&
        $x <  $dx + $self->rect->x + $self->rect->w &&
        $y >= $dy + $self->rect->y                  &&
        $y <  $dy + $self->rect->y + $self->rect->h;

    return 0;
}

=head2 parent $parent

Get or set $parent surface.

=cut

sub parent  {
    my ($self, $parent) = @_;
    $self->{parent} = $parent if defined $parent;
    return $self->{parent};
}

=head2 disable $disable

Disable or enable button by $disable bool flag.

=cut

sub disable
{
    my ($self, $disable) = @_;
    $self->{disable} = ($disable) ?1 :0 if defined $disable;
    return $self->{disable};
}

1;