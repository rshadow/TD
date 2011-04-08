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
    croak 'Missing required param "dt"'      unless defined $opts{dt};

    my $self = bless \%opts, $class;

    $self->_init_units;

    return $self;
}

sub _init_units
{
    my ($self, $app) = @_;

    for my $name ($self->names)
    {
        # Get start position
        my $x           = $self->map->start($name)->x * $self->map->tail_width;
        my $y           = $self->map->start($name)->y * $self->map->tail_height;
        # Get start direction
        my $direction   = $self->map->start($name)->direction($name);

        # Subtrac start position on one tail by direction
        if   ($direction eq 'left')  { $x += $self->map->tail_width; }
        elsif($direction eq 'right') { $x -= $self->map->tail_width; }
        elsif($direction eq 'up')    { $y += $self->map->tail_height; }
        elsif($direction eq 'down')  { $y -= $self->map->tail_height; }
        else                         { die 'Broken start direction'; }

        for my $unit (@{ $self->path($name) })
        {
            $unit = Game::TD::Unit->new(
                type        => $unit->{type},
                x           => $x,
                y           => $y,
                direction   => $direction,
                span        => $unit->{span},
                path        => $name,
            );

            # Store type
            $self->types( $unit->type );
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
sub dt  { return shift()->{dt};   }

sub update
{
    my ($self, $ticks) = @_;

    my %result;

    # Get active units
    my $active = $self->active($ticks);

#    use Data::Dumper;
#    die Dumper $active;
    # Move active units
    $_->move( $self->dt ) for @$active;

    for my $unit ( @$active )
    {
        # Get current tail for unit
        my $tail = $self->map->tail( $self->map_xy($unit) );

        # If no tail - unit move from map
        unless ($tail)
        {
            $result{damage} += $unit->health;
            $unit->die('reach');
        }
        else
        {
            # Try change direction as in tail
            $unit->direction($tail->direction($unit->path) );
        }
    }

    return %result;
}

sub active
{
    my ($self, $ticks) = @_;

    if( defined $ticks )
    {
        # Drop active list
        $self->{active} = [];

        # Find active units for all paths and store them
        for my $name ($self->names)
        {
            my @active =
                grep { $_->span <= $ticks and !$_->is_die } $self->path($name);
            @{$self->{active}} = (@{$self->{active}}, @active);
        }
    }

    return wantarray ?@{ $self->{active} } : $self->{active};
}

sub map_xy
{
    my ($self, $unit) = @_;

    my $map_x = int( $unit->x / $self->map->tail_width  );
    my $map_y = int( $unit->y / $self->map->tail_height );

    my $tail_x = $map_x * $self->map->tail_width;
    my $tail_y = $map_y * $self->map->tail_height;

    if($unit->direction eq 'up')
    {
        $map_y += 1 if $unit->y > $tail_y;
    }
    elsif($unit->direction eq 'left')
    {
        $map_x += 1 if $unit->x > $tail_x;
    }

    return ($map_x, $map_y);
}

sub types
{
    my ($self, $type) = @_;
    $self->{types}{$type}++ if defined $type;
    return wantarray ? %{$self->{types}} : $self->{types};
}

1;