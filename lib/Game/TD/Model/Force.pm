use strict;
use warnings;
use utf8;

package Game::TD::Model::Force;
#use base qw(Exporter);
#our @EXPORT = qw();

use Carp;
use Scalar::Util qw(weaken);
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

    $self->{types} = config->param('tower'=>'towers');

    return $self;
}

=head2 types $type

Store new $type if parameter defined. If $type not set then return types list.

=cut

sub types
{
    my ($self, $type) = @_;
    return wantarray ? keys %{$self->{types}} : [keys %{$self->{types}}];
}

=head2 build $type, $tile

Build tower $type on $tile

=cut

sub build
{
    my ($self, $type, $tile) = @_;

    # Create tower name
    my $name  = $tile->x .'x'. $tile->y;

    # Create tower
    my $tower = Game::TD::Model::Tower->new(type => $type, name => $name);

    # Set tower on map
    $tile->item_add('tower' => $tower->type);

    # Save new tower in pull
    $self->{towers}{$name} = $tower;

    weaken $tower;
    return $tower;
}

=head2 tower $name

Return tower by $name

=cut

sub tower
{
    my ($self, $name) = @_;
    return $self->{towers}{$name};
}

sub active
{
    my ($self) = @_;

    return wantarray ? values %{$self->{towers}} : [values %{$self->{towers}}];
}

=head2 attr $type, $attr, $value

Set/get default tower $type attribute $attr

=cut

sub attr
{
    my ($self, $type, $attr, $value) = @_;

    croak 'Missing required param "type"'   unless defined $type;
    croak 'Missing required param "attr"'   unless defined $attr;

    $self->{types}{$type}{$attr} = $value if defined $value;
    return $self->{types}{$type}{$attr};
}

1;