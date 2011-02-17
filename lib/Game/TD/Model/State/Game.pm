use strict;
use warnings;
use utf8;

package Game::TD::Model::State::Game;

use Game::TD::Config;

=head1 Game::TD::Model::State::Game

Описание_модуля

=cut

=head1 Функции

=cut

=head2 new HASH

Конструктор

=head3 Входные параметры

=head4 параметр

=cut

sub new
{
    my ($class, %opts) = @_;

    die 'Missing required param "level"'    unless defined $opts{level};
    die 'Missing required param "player"'   unless defined $opts{player};

    my $self = bless \%opts, $class;

    # Load level hash
    my ($file) =
        glob sprintf '%s/%d.*.level', config->dir('level'), $self->level;
    my %level = do $file;
    die $@ if $@;

    # Concat
    $self->{$_} = $level{$_} for keys %level;

    return $self;
}

sub update
{
    my $self = shift;

    return 0 if $self->health <= 0;
    return 1;
}

sub level   { return shift()->{level};  }
sub player  { return shift()->{player}; }

sub name
{
    my ($self) = @_;
    die 'Missing "name" parameter in level file'
        unless defined $self->{name};
    return $self->{name};
}

sub title
{
    my ($self) = @_;
    die 'Missing "title" parameter in level file'
        unless defined $self->{title};
    return $self->{title};
}

sub map
{
    my ($self) = @_;
    die 'Missing "map" parameter in level file'
        unless defined $self->{map};
    return (wantarray) ? @{$self->{map}} :$self->{map};
}

sub wave
{
    my ($self) = @_;
    die 'Missing "wave" parameter in level file'
        unless defined $self->{wave};
    return (wantarray) ? @{$self->{wave}} :$self->{wave};
}

sub sleep
{
    my ($self) = @_;
    die 'Missing "sleep" parameter in level file'
        unless defined $self->{sleep};
    return $self->{sleep};
}

sub health
{
    my ($self) = @_;
    die 'Missing "health" parameter in level file'
        unless defined $self->{health};
    return $self->{health};
}

1;