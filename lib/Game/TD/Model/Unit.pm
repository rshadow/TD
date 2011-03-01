use strict;
use warnings;
use utf8;

package Game::TD::Model::Unit;
#use base qw(Exporter);
#our @EXPORT = qw();

use Carp;

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

    die 'Missing required param "type"'         unless defined $opts{type};
    die 'Missing required param "x"'            unless defined $opts{x};
    die 'Missing required param "y"'            unless defined $opts{y};
    die 'Missing required param "direction"'    unless defined $opts{direction};

    my $self = bless \%opts, $class;

    # Get from config
    my %unit = config->param('unit'=>$self->type);
    # Concat
    $self->{$_} = $unit{$_} for keys %unit;

    return $self;
}

sub type    {return shift()->{type}     }
sub speed   {return shift()->{speed}    }
sub health  {return shift()->{health}   }

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

    if($self->direction eq 'left')
    {
        $self->x( $self->x - $self->speed * ($dt / 1000));
    }
    elsif($self->direction eq 'right')
    {
        $self->x( $self->x + $self->speed * ($dt / 1000));
    }
    elsif($self->direction eq 'up')
    {
        $self->y( $self->y - $self->speed * ($dt / 1000));
    }
    elsif($self->direction eq 'down')
    {
        $self->y( $self->y + $self->speed * ($dt / 1000));
    }
    else
    {
        confess 'Unknown direction';
    }
}

1;