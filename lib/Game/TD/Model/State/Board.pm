use strict;
use warnings;
use utf8;

package Game::TD::Model::State::Board;
use base qw(Game::TD::Model);

use Game::TD::Config;

=head1 Game::TD::Model::State::Board

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

    my $self = $class->SUPER::new(%opts);

    $self->{levels} = [ glob sprintf '%s/*.level', config->dir('level') ];
    die 'No levels found' unless @{ $self->{levels} };

    return $self;
}

sub levels
{
    my ($self) = @_;
    return wantarray ? %{$self->{levels}} : $self->{levels};
}

sub current
{
    my ($self, $current) = @_;
    $self->{current} = $current if defined $current;
    return $self->{current};
}


1;