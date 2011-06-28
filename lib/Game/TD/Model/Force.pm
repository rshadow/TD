use strict;
use warnings;
use utf8;

package Game::TD::Model::Force;
#use base qw(Exporter);
#our @EXPORT = qw();

use Carp;
use Game::TD::Config;
use Game::TD::Model::Tower;

=head1 Game::TD::Model::Force

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

    $self->types($_) for keys %{ config->param('tower'=>'towers') };

    return $self;
}

=head2 types $type

Store new $type if parameter defined. If $type not set then return types list.

=cut

sub types
{
    my ($self, $type) = @_;
    $self->{types}{$type}++ if defined $type;
    return wantarray ? keys %{$self->{types}} : [keys %{$self->{types}}];
}

=head2 build $type, $tile

Build tower $type on $tile

=cut

sub build
{
    my ($self, $type, $tile) = @_;

    # Create tower
    my $tower = Game::TD::Model::Tower->new(type => $type);
    # Create tower name
    my $name  = $tile->x .'x'. $tile->y;

    # Set tower on map
    $tile->item_add('tower' => $tower->type);

    # Save new tower in pull
    $self->{towers}{$name} = $tower;
}

sub active
{
    my ($self) = @_;

    return wantarray ? values %{$self->{towers}} : [values %{$self->{towers}}];
}

1;