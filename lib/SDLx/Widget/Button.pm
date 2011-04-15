use strict;
use warnings;
use utf8;

package SDLx::Widget::Button;
use base qw(SDLx::Sprite::Animated);

use Carp;

use SDL;
use SDL::Event;
use SDL::Events;
use SDLx::Text;

use Game::TD::Config;

=head1 NAME

Game::TD::Model::Button - Модуль

=head1 SYNOPSIS

  use Game::TD::Model::Button;

=head1 DESCRIPTION

=cut

=head1 METHODS

=cut

sub new
{
    my ($class, %opts) = @_;

    confess 'Need SDLx::App or SDLx::Surface as parent'
        unless defined $opts{parent};

#    $opts{disable} //= 0;

    my $self = $class->SUPER::new(%opts);

    $self->parent( $opts{parent} );
    $self->disable( $opts{disable} // 0 );
    $self->state('out');
    $self->sequence('out');

    return $self;
}

sub state
{
    my ($self, $state) = @_;
    $self->{state} = $state if defined $state;
    return $self->{state};
}

sub event
{
    my ($self, $event, $app) = @_;

    my $type = $event->type;

    if($type == SDL_MOUSEMOTION)
    {
        if( $self->is_over($event->motion_x, $event->motion_y) )
        {
            $self->state('over') unless $self->state eq 'down';
        }
        else
        {
            $self->state('out')
        }
    }
    elsif($type == SDL_MOUSEBUTTONDOWN && ! $self->disable)
    {
        if( $event->button_button == SDL_BUTTON_LEFT )
        {
            $self->state('down')
                if $self->is_over($event->button_x, $event->button_y);
        }
    }
    elsif($type == SDL_MOUSEBUTTONUP && ! $self->disable)
    {
        # Check 'down' for prevent press from another state
        if($self->state eq 'down')
        {
            if( $event->button_button == SDL_BUTTON_LEFT )
            {
                $self->state('up')
                    if $self->is_over($event->button_x, $event->button_y);
            }
        }
    }

    return $self->state;
}

sub draw
{
    my ($self, $surface) = @_;

    $surface //= $self->parent;

    my $sequence = $self->state;
    $sequence = 'd_'.$sequence if $self->disable;
    $self->sequence( $sequence );
#use Data::Dumper;
#die Dumper $surface, $self->parent, $sequence;
    $self->SUPER::draw($surface);

#    $self->font('text')->write_xy(
#        $self->parent->surface,
#        $self->dest('text')->x,
#        $self->dest('text')->y,
#    ) if $self->font('text');

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

sub parent  {
    my ($self, $parent) = @_;
    $self->{parent} = $parent if defined $parent;
    return $self->{parent};
}

sub disable
{
    my ($self, $disable) = @_;
    $self->{disable} = $disable if defined $disable;
    return $self->{disable};
}

1;