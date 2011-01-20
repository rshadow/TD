package Game::TD::Model::Button;

use warnings;
use strict;
use utf8;

=head1 NAME

Game::TD::Model::Button - Модуль

=head1 SYNOPSIS

  use Game::TD::Model::Button;

=head1 DESCRIPTION

=cut

=head1 METHODS

=cut

use constant STATE_MOUSE_OVER   => 'mouse_over';
use constant STATE_MOUSE_OUT    => 'mouse_out';
use constant STATE_MOUSE_DOWN   => 'mouse_down';
use constant STATE_MOUSE_UP     => 'mouse_up';

sub new
{
    my ($class, %opts) = @_;

    die 'Param left required'   unless defined $opts{left};
    die 'Param top required'    unless defined $opts{top};
    die 'Param width required'  unless defined $opts{width};
    die 'Param height required' unless defined $opts{height};

    $opts{state} //= STATE_MOUSE_OUT;

    my $self = bless \%opts, $class;



    return $self;
}

sub state
{
    my ($self, $state) = @_;
    $self->{state} = $state if defined $state;
    return $self->{state};
}

sub update
{
    my ($self, $x, $y) = @_;

    if(
        $x > $self->left                &&
        $x < $self->left + $self->width &&
        $y > $self->top                 &&
        $y < $self->top + $self->height
    )
    {
        $self->state(STATE_MOUSE_OVER);
    }
    else
    {
        $self->state(STATE_MOUSE_OUT);
    }

}

sub left    {return shift()->{left}  }
sub top     {return shift()->{top}   }
sub width   {return shift()->{width} }
sub height  {return shift()->{height}}
1;