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

    my $self = bless \%opts, $class;

    return $self;
}

1;