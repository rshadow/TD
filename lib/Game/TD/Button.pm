use strict;
use warnings;
use utf8;

package Game::TD::Button;
use base qw(Game::TD::View);

use Carp;
use SDL;
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

    my $self = bless \%opts, $class;

    # Get params from config by conf name and button name
    $self->{left}   = int(config->param($self->conf=>$self->name=>'left'));
    $self->{top}    = int(config->param($self->conf=>$self->name=>'top'));
    $self->{file}   = config->param($self->conf=>$self->name=>'file');
    $self->{text}   = config->param($self->conf=>$self->name=>'text');

    $self->img(background => SDL::Surface->new(
        -name   => $self->file,
        -flags  => SDL_HWSURFACE
    ));
#    $self->img('background')->display_format;
    # Image size
    $self->{width}  = int($self->img('background')->width  / 2);
    $self->{height} = int($self->img('background')->height / 2);
    $self->size(background => SDL::Rect->new(
        -width  => $self->width,
        -height => $self->height
    ));

    # Draw destination - all window
    $self->dest(background => SDL::Rect->new(
        -left   => $self->left,
        -top    => $self->top,
        -width  => $self->width,
        -height => $self->height
    ));

    # Clip image states
    $self->clip(over => SDL::Rect->new(
        -left   => 0,
        -top    => 0,
        -width  => $self->width,
        -height => $self->height
    ));
    $self->clip(out => SDL::Rect->new(
        -left   => $self->width,
        -top    => 0,
        -width  => $self->width,
        -height => $self->height
    ));
    $self->clip(down => SDL::Rect->new(
        -left   => 0,
        -top    => $self->height,
        -width  => $self->width,
        -height => $self->height
    ));
    $self->clip(up => SDL::Rect->new(
        -left   => $self->width,
        -top    => $self->height,
        -width  => $self->width,
        -height => $self->height
    ));

    # If button have text then load font for it
    if( length $self->text )
    {
        my $font  = config->param($self->conf=>$self->name=>'font');
        my $size  = config->param($self->conf=>$self->name=>'size');
        my %color = config->color($self->conf=>$self->name=>'color');

        if($self->name and $font and $size and %color)
        {
            $self->font(text => SDL::TTFont->new(
                -name => $font,
                -size => $size,
                -mode => SDL::UTF8_SOLID,
                -fg   => SDL::Color->new(%color),
            ));
        }
    }

    # Check initial state
    my ($x, $y) = @{ SDL::GetMouseState() }[1 .. 2];
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
    elsif($type == SDL_MOUSEBUTTONDOWN)
    {
        if( $event->button == SDL_BUTTON_LEFT )
        {
            $self->state('down')
                if $self->is_over($event->button_x, $event->button_y);
        }
    }
    elsif($type == SDL_MOUSEBUTTONUP)
    {
        # Check 'down' for prevent press from another state
        if($self->state eq 'down')
        {
            if( $event->button == SDL_BUTTON_LEFT )
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
    my $self = shift;

    $self->img('background')->blit(
        $self->clip($self->state), $self->app, $self->dest('background'));

    $self->font('text')->print(
        $self->app,
        $self->dest('background')->left,
        $self->dest('background')->top,
        $self->text
    ) if $self->font('text');

    return 1;
}

=head2 is_over $x, $y

Check if $x and $y coordinates within button rect

=cut

sub is_over
{
    my ($self, $x, $y) = @_;
    return 1 if
        $x > $self->left                &&
        $x < $self->left + $self->width &&
        $y > $self->top                 &&
        $y < $self->top + $self->height;
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

sub clip
{
    my ($self, $name, $value) = @_;

    die 'Name required'             unless defined $name;
    $self->{clip}{$name} = $value   if defined $value;
    return $self->{clip}{$name};
}

1;