package Game::TD::Model::Player;

use warnings;
use strict;
use utf8;

=head1 NAME

Game::TD::Player - Store all player parameters

=head1 SYNOPSIS

  use Game::TD::Player;

=head1 DESCRIPTION

=cut

=head1 METHODS

=cut

sub new
{
    my ($class, %opts) = @_;

    $opts{score} //= 0;
    $opts{name}  //= getlogin || getpwuid($<) || "player";
    $opts{level} //= 1;
    $opts{money} //= 100;
    $opts{difficult} //= 'normal';

    my $self = bless \%opts, $class;

    return $self;
}

=head2 score

Get/Set player score

=cut

sub score
{
    my ($self, $score) = @_;
    $self->{score} = $score if defined $score;
    return $self->{score};
}

=head2 name

Get/Set player name

=cut

sub name
{
    my ($self, $name) = @_;
    $self->{name} = $name if defined $name;
    return $self->{name};
}

=head2 money

Get/Set player money

=cut

sub money
{
    my ($self, $money) = @_;
    $self->{money} = $money if defined $money;
    return $self->{money};
}

=head2 difficult

Get/Set player difficult level: easy, normal, hard

=cut

sub difficult
{
    my ($self, $difficult) = @_;
    if( defined $difficult )
    {
        die 'Unknown difficult' unless $difficult =~ m/^(?:easy|normal|hard)$/;
        $self->{difficult} = $difficult;
    }
    return $self->{difficult};
}

=head2 level

Return player level

=cut

sub level
{
    my ($self) = @_;
    return $self->{level};
}

=head2 levelup

Make level up for player and return new level;

=cut

sub levelup
{
    my ($self) = @_;
    $self->{level} ++;
    return $self->{level};
}

1;