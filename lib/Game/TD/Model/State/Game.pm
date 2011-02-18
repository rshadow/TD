use strict;
use warnings;
use utf8;

package Game::TD::Model::State::Game;

use Game::TD::Config;
use Game::TD::Model::Timer;

use constant TAIL_WIDTH     => 50;
use constant TAIL_HEIGHT    => 50;

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

    $self->timer('sleep' => Game::TD::Model::Timer->new() );
    $self->timer('sleep')->start;

    return $self;
}

sub update
{
    my $self = shift;


    if( $self->sleep )
    {
        $self->left( $self->sleep - $self->timer('sleep')->get_ticks );
        return 1;
    }

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

=head2 left

Get/Set counter for game start. See <i>sleep</i> function.

=cut

sub left
{
    my ($self, $value) = @_;
    if( defined $value )
    {
        $self->{left} = ($value > 0) ?$value : 0;
    }
    return $self->{left};
}

sub health
{
    my ($self) = @_;
    die 'Missing "health" parameter in level file'
        unless defined $self->{health};
    return $self->{health};
}

sub timer
{
    my ($self, $name, $timer) = @_;
    die 'Missing required parameter "name"' unless defined $name;
    $self->{timer}{$name} = $timer if defined $timer;
    return $self->{timer}{$name};
}

sub tail_width  { return TAIL_WIDTH  }
sub tail_height { return TAIL_HEIGHT }
1;