use strict;
use warnings;
use utf8;

package Game::TD::Model::Level;

=head1 Game::TD::Model::Level

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

    $opts{current} //= 0;

    my $self = bless \%opts, $class;

    return $self;
}

1;