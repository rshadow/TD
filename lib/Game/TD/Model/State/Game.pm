use strict;
use warnings;
use utf8;

package Game::TD::Model::State::Game;
use base qw(Game::TD::Model);

use Game::TD::Config;
use Game::TD::Model::Level;

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

    my $num = delete $opts{level};

    my $self = bless \%opts, $class;

    $self->level(Game::TD::Model::Level->new(num => $num));

    $self->timer('sleep'=>'new');
    $self->left( $self->level->sleep - $self->timer('sleep')->get_ticks );

    $self->timer('sleep')->start;

    return $self;
}

sub update
{
    my $self = shift;

    # Sleep timer
    if( $self->left)
    {
        $self->left( $self->level->sleep - $self->timer('sleep')->get_ticks );
        return 1;
    }

    $self->level->update;

    return 0 if $self->level->health <= 0;
    return 1;
}

sub player      { return shift()->{player};     }

sub level
{
    my ($self, $level) = @_;
    $self->{level} = $level if defined $level;
    return $self->{level};
}

=head2 left

Get/Set counter for game start. See <i>Game::TD::Model::Level::sleep</i>
function.

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

1;