use strict;
use warnings;
use utf8;

package Game::TD::Button;
use base qw(Game::TD::View);

use Carp;

use SDL;
use SDL::Event;
use SDL::Events;
use SDLx::Sprite;
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

    croak 'Missing required param "app"' unless defined $opts{app};
    croak 'Missing required param "conf' unless defined $opts{conf};
    croak 'Missing required param "name' unless defined $opts{name};

    $opts{disable} //= 0;

    my $self = bless \%opts, $class;

    # Get params from config by conf name and button name
    $self->{left}   //= int(config->param($self->conf=>$self->name=>'left') || 0);
    $self->{top}    //= int(config->param($self->conf=>$self->name=>'top')  || 0);
    $self->{file}   //= config->param($self->conf=>$self->name=>'file');
    $self->{text}   //= config->param($self->conf=>$self->name=>'text');

    $self->sprite(background => SDLx::Sprite->new(image => $self->file));

    # Image size
    $self->{width}  = int($self->sprite('background')->w  / 2);
    $self->{height} = $self->{width};

    # Draw destination - all window
    $self->sprite('background')->rect(SDL::Rect->new(
        $self->left, $self->top, $self->width, $self->height));

    # Clip image states
    $self->clip(over => SDL::Rect->new(
        0, 0,
        $self->width, $self->height
    ));
    $self->clip(out => SDL::Rect->new(
        $self->width, 0,
        $self->width,$self->height
    ));
    $self->clip(down => SDL::Rect->new(
        0, $self->height,
        $self->width, $self->height
    ));
    $self->clip(up => SDL::Rect->new(
        $self->width, $self->height,
        $self->width, $self->height
    ));
    $self->clip(d_over => SDL::Rect->new(
        0, $self->height * 2,
        $self->width, $self->height
    ));
    $self->clip(d_out => SDL::Rect->new(
        $self->width, $self->height * 2,
        $self->width, $self->height
    ));

    # If button have text then load font for it
    if( $self->text and length $self->text )
    {
        my $font  = config->param($self->conf=>$self->name=>'font');
        my $size  = config->param($self->conf=>$self->name=>'size');
        my $color = config->color($self->conf=>$self->name=>'color');

        if($self->name and $font and $size and $color)
        {
            $self->font(text => SDLx::Text->new(
                font    => $font,
                size    => $size,
                color   => $color,
                mode    => 'utf8',
            ));

            $self->font('text')->text( $self->text );

            $self->dest(text => $self->sprite('background')->rect);
        }
    }

    # Check initial state
    my ($x, $y) = @{ SDL::Events::get_mouse_state() }[1 .. 2];
    $self->is_over($x, $y) ?$self->state('over') :$self->state('out');

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
    my ($self, $event) = @_;

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
    my ($self) = @_;

    my $surface = ($self->parent) ?$self->parent->surface :$self->app;

    # Get clip for current state
    my $state = $self->state;
    # Fix clip if button disabled
    $state = (($self->state eq 'out') ?'d_out' : 'd_over')
        if $self->disable;

    $self->sprite('background')->clip( $self->clip($state) );
    $self->sprite('background')->draw( $surface );

    $self->font('text')->write_xy(
        $surface,
        $self->dest('text')->x,
        $self->dest('text')->y,
    ) if $self->font('text');

    return 1;
}

=head2 is_over $x, $y

Check if $x and $y coordinates within button rect

=cut

sub is_over
{
    my ($self, $x, $y) = @_;

    my ($dx, $dy) = ($self->parent)
        ?($self->parent->x, $self->parent->y) :(0,0);

    return 1 if
        $x >= $dx + $self->left                &&
        $x <  $dx + $self->left + $self->width &&
        $y >= $dy + $self->top                 &&
        $y <  $dy + $self->top + $self->height;
    return 0;
}

sub name    {return shift()->{name}  }
sub file    {return shift()->{file}  }
sub conf    {return shift()->{conf}  }
sub left    {return shift()->{left}  }
sub top     {return shift()->{top}   }
sub width   {return shift()->{width} }
sub height  {return shift()->{height}}
sub text    {return shift()->{text}  }
sub parent  {return shift()->{parent}}

sub clip
{
    my ($self, $name, $value) = @_;

    confess 'Name required'             unless defined $name;
    $self->{clip}{$name} = $value   if defined $value;
    return $self->{clip}{$name};
}

sub disable
{
    my ($self, $disable) = @_;
    $self->{disable} = $disable if defined $disable;
    return $self->{disable};
}

DESTROY
{
    my $self = shift;

    undef $self->{clip}{$_} for keys %{ $self->{clip} };
}

1;