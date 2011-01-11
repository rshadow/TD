use strict;
use warnings;
use utf8;

package Game::TD::Model::Menu;

=head1 Game::TD::Model::Menu

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

    $self->{items} = ['start', 'score', 'exit'];

    return $self;
}

sub up
{
    my $self = shift;
    $self->{current}-- if $self->{current} > 0;
    return 1;
}

sub down
{
    my $self = shift;
    $self->{current}++ if $self->{current} < $#{$self->{items}};
    return 1;
}

sub current
{
    my $self = shift;
    return $self->{current};
}

1;