use strict;
use warnings;
use utf8;

package Game::TD::Model::Wave;
#use base qw(Exporter);
#our @EXPORT = qw();

use Carp;
use Game::TD::Unit;

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

    croak 'Missing required param "wave"'    unless defined $opts{wave};
    croak 'Missing required param "map"'     unless defined $opts{map};

    my $self = bless \%opts, $class;


    return $self;
}

sub _init_units
{
    my ($self) = @_;
    for my $name ($self->names)
    {
        for my $unit ( $self->path($name) )
        {
            $unit = Game::TD::Unit->new(
                app         => $self->app,
                type        => $unit->{type},
                x   => $self->map->start($name)->x * $self->map->tail_width,
                y   => $self->map->start($name)->y * $self->map->tail_height,
                direction   => 'right', #???
                span        => $unit->{span},
            );
        }
    }
}

sub wave
{
    my $self = shift;
    return wantarray ? %{ $self->{wave} } : $self->{wave};
}

sub names
{
    my $self = shift;
    return wantarray ? keys %{ $self->{wave}} : scalar keys %{ $self->{wave}};
}

sub path
{
    my ($self, $name) = @_;
    return wantarray ?@{ $self->{wave}{$name} } :$self->{wave}{$name};
}


sub map { return shift()->{map} }
1;