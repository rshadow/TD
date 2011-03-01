use strict;
use warnings;
use utf8;

package Game::TD::Model::Wave;
#use base qw(Exporter);
#our @EXPORT = qw();

use Game::TD::Model::Unit;

=head1 Game::TD::Model::Wave

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

    die 'Missing required param "wave"'    unless defined $opts{wave};

    my $self = bless \%opts, $class;

    for my $wave ( @{ $self->{wave} } )
    {
        for my $path ( @{$wave->{path}} )
        {
            for my $unit (@{$wave->{units}})
            {
                $unit = Game::TD::Model::Unit->new(
                    type        => $unit,
                    x           => 0,
                    y           => 100,
                    direction   => 'right',
                );
            }
        }
    }

    return $self;
}

sub wave
{
    my ($self) = @_;
    return $self->{wave}[$self->current];
}

sub waves_count
{
    my ($self) = @_;
    return scalar @{ $self->{wave} };
}

sub path_count
{
    my ($self) = @_;
    return scalar @{ $self->{wave}[$self->current]{path} };
}

sub current
{
    my ($self) = @_;
    return $self->{current};
}

sub next
{
    my ($self) = @_;
    return $self->{current}+=1;
}

1;