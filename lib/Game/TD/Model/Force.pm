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
    my $name  = $tile->m_x .'x'. $tile->m_y;

    # Create tower
    my $tower = Game::TD::Model::Tower->new(
        type => $type,
        name => $name,
        tile => $tile);

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

sub update
{
    my ($self, $t, $units) = @_;

    return unless $units;

    for my $tower ($self->active)
    {
        # Skip if tower praparing for shot
        next if $tower->prepare and $tower->preparing($t);

        for my $unit (@$units)
        {
            # Skip if unit unreachible
            next unless $self->_is_reached($tower, $unit);

            # Try to shot
            $self->shot($tower, $unit);
            # Just one shot per tower
            last;
        }
    }
}

sub _is_reached
{
    my ($self, $tower, $unit) = @_;

    my $x1 = $unit->x;
    my $y1 = $unit->y;

    my $x2 = $tower->tile->x;
    my $y2 = $tower->tile->y;

    my $distance = int sqrt( ($x2 - $x1) ** 2 + ($y2 - $y1) ** 2 );

    my $reached = ($distance <= $tower->range) ? 1 : 0;

#    printf "%s: unit:%sx%s tower:%sx%s reached:%s\n",
#        $tower->name, $x1, $y1, $x2, $y2, $reached;

    return $reached;
}

sub shot
{
    my ($self, $tower, $unit) = @_;

    $unit->hit( $tower->damage );
    $tower->prepare( $tower->speed );
}
1;