use strict;
use warnings;
use utf8;

package Game::TD::Model::Cursor;
#use base qw(Exporter);
#our @EXPORT = qw();

=head1 NAME

Game::TD::Model::Cursor

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

    $opts{state} = 'default';

    my $self = bless \%opts, $class;

    return $self;
}

sub state
{
    my ($self, $state) = @_;
    $self->{state} = $state if defined $state;
    return $self->{state};
};

1;