package SDLx::Button;
use strict;
use warnings;
use utf8;

use SDL;

use Carp ();

sub new {
    my ( $class, %options ) = @_;

    Carp::confess 'Need a sprite => SDLx::Sprite'
        unless exists $options{sprite};

    my $self = bless {}, $class;

    $self->_init_rects(%options);


    return $self;
}

sub _init_rects {
    my ( $self, %options ) = @_;

    return $self->clips( $options{clips} )
        if exists $options{clips};

    $self->step_x( $self->sprite->w / 6 );

    my @clips;
    push @clips,
        mSDLx::Rect->new($self->step_x * $_, 0, $self->sprite->h, $self->step_x)
            for 0 .. 6;

    $self->clips(\@clips);
}

sub _is_over
{
    my ($self, $x, $y) = @_;
    return 1 if
        $x > $self->sprite->x                   &&
        $x < $self->sprite->x + $self->step_x   &&
        $y > $self->sprite->y                   &&
        $y < $self->sprite->y + $self->sprite->h;
    return 0;
}

sub clips {
    my ( $self, $clips ) = @_;

    # short-circuit
    return $self->{clips} unless $clips;

    Carp::confess 'Clips array length not 6'
        unless 6 == length @$clips;

    return $self->{clips} = $clips;
}

sub step_x
{
    my ( $self, $step_x ) = @_;

    # short-circuit
    return $self->{step_x} unless $step_x;

    return $self->{step_x} = $step_x;
}

sub sprite
{
    my ( $self, $sprite ) = @_;

    # short-circuit
    return $self->{sprite} unless $sprite;

    return $self->{sprite} = $sprite;
}

sub state
{
    my ($self, $state) = @_;

    # short-circuit
    return $self->{state} unless $state;

    return $self->{state};
}


1;
