use strict;
use warnings;
use utf8;

package Game::TD::Model::Unit;

use Carp;

use Game::TD::Config;

=head1 NAME

Game::TD::Model::Unit - Модуль

=head1 SYNOPSIS

  use Game::TD::Model::Unit;

=head1 DESCRIPTION

=cut

=head1 METHODS

=cut

sub new
{
    my ($class, %opts) = @_;

    croak 'Missing required param "type"'       unless defined $opts{type};
    croak 'Missing required param "x"'          unless defined $opts{x};
    croak 'Missing required param "y"'          unless defined $opts{y};
    croak 'Missing required param "direction"'  unless defined $opts{direction};
    croak 'Missing required param "span"'       unless defined $opts{span};
    croak 'Missing required param "path"'       unless defined $opts{path};
    croak 'Missing required param "index"'      unless defined $opts{index};

    my $self = bless \%opts, $class;

    # Get from config
    my %unit = %{ config->param('unit'=>$self->type) || {} };
    %unit = %{ config->param('unit'=>'unknown') } unless %unit;

    # Concat
    $self->{$_} = $unit{$_} for qw(speed health);

    $self->{id} = $self->type .'_'. $self->path .'_'. $self->index;

    return $self;
}

sub id      {return shift()->{id}       }
sub type    {return shift()->{type}     }
sub path    {return shift()->{path}     }
sub speed   {return shift()->{speed}    }
sub health  {return shift()->{health}   }
sub index   {return shift()->{index}    }

sub conf
{
    my $self = shift;
    return $self->{conf} // 'unit';
}

sub direction
{
    my ($self, $direction) = @_;
    $self->{direction} = $direction if defined $direction;
    return $self->{direction};
}

sub x
{
    my ($self, $x) = @_;
    $self->{x} = $x if defined $x;
    return $self->{x};
}

sub y
{
    my ($self, $y) = @_;
    $self->{y} = $y if defined $y;
    return $self->{y};
}

sub move
{
    my ($self, $dt) = @_;

    # Do not move die unit
    return unless $self->health;
    return unless $self->speed;
    return unless $self->direction;

    # Move unit
    if($self->direction eq 'left')
    {
        $self->x( $self->x - $self->speed * $dt);
    }
    elsif($self->direction eq 'right')
    {
        $self->x( $self->x + $self->speed * $dt);
    }
    elsif($self->direction eq 'up')
    {
        $self->y( $self->y - $self->speed * $dt);
    }
    elsif($self->direction eq 'down')
    {
        $self->y( $self->y + $self->speed * $dt);
    }
    else
    {
        confess 'Unknown direction';
    }
}

sub span
{
    my ($self, $span) = @_;
    $self->{span} = $span if defined $span;
    return $self->{span};
}

sub is_die
{
    my ($self) = @_;
    return $self->{health} ?0 :1;
}

sub die
{
    my ($self, $type) = @_;

    $self->{health}     = 0;
    $self->{speed}      = 0;
    $self->{direction}  = undef;
}

1;