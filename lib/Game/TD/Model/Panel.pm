use strict;
use warnings;
use utf8;

package Game::TD::Model::Panel;
#use base qw(Exporter);
#our @EXPORT = qw();

=head1 Game::TD::Model::Panel

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

    $opts{visible} //= 1;

    my $self = bless \%opts, $class;

    return $self;
}

sub visible { return shift()->{visible} }

1;