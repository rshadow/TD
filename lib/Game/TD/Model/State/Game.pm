use strict;
use warnings;
use utf8;

package Game::TD::Model::State::Game;

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

    die 'Missing required param "level"' unless defined $opts{level};

    my $self = bless \%opts, $class;

    $self->level( Game::TD::Model::Level->new(level => $opts{level}) );

    return $self;
}

sub level
{
    my ($self, $level) = @_;
    $self->{level} = $level if defined $level;
    return $self->{level};
}

1;