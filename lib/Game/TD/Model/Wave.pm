use strict;
use warnings;
use utf8;

package Game::TD::Model::Wave;
#use base qw(Exporter);
#our @EXPORT = qw();

use Carp;
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

    croak 'Missing required param "wave"'    unless defined $opts{wave};
    croak 'Missing required param "map"'     unless defined $opts{map};
    croak 'Missing required param "dt"'      unless defined $opts{dt};

    my $self = bless \%opts, $class;

    $self->_init_units;

    confess 'No units' if $self->is_empty;

    return $self;
}

sub _init_units
{
    my ($self, $app) = @_;

    for my $name ($self->names)
    {
        # Get start position
        my $x           = $self->map->start($name)->x;
        my $y           = $self->map->start($name)->y;
        # Get start direction
        my $direction   = $self->map->start($name)->direction($name);

        # Subtrac start position on one tile by direction
        if   ($direction eq 'left')  { $x += $self->map->tile_width; }
        elsif($direction eq 'right') { $x -= $self->map->tile_width; }
        elsif($direction eq 'up')    { $y += $self->map->tile_height; }
        elsif($direction eq 'down')  { $y -= $self->map->tile_height; }
        else                         { die 'Broken start direction'; }

        for my $index (0 .. $#{ $self->path($name) })
        {
            my $unit = $self->path($name)->[$index];

            $unit = Game::TD::Model::Unit->new(
                type        => $unit->{type},
                x           => $x,
                y           => $y,
                direction   => $direction,
                span        => $unit->{span},
                path        => $name,
                index       => $index,
            );

            $self->path($name)->[$index] = $unit;

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
        # Get current tile for unit
        my $tile = $self->map->tile(
            $self->map->xy2map(
                $unit->x,
                $unit->y,
                $unit->direction ));

        # If no tile - unit move from map
        unless ($tile)
        {
            $result{damage} += $unit->health;
            $unit->die('reach');
        }
        else
        {
            # Try change direction as in tile
            $unit->direction($tile->direction($unit->path) );
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

=head2 is_empty

Return true if wave empty

=cut

sub is_empty
{
    my ($self) = @_;

    # Quick check for paths
    return 1 unless $self->names;

    # If some units not die then return false
    for my $name ($self->names)
    {
        for my $unit ( reverse $self->path($name) )
        {
            return 0 unless $unit->is_die;
        }
    }

    # All units die then return true
    return 1;
}

#=head2 unit_xy $x, $y, @units
#
#Verify is locical map $x $y have some untits from @units and return this units
#
#=cut
#
#sub unit_xy
#{
#    my ($self, $x, $y, @units) = @_;
#
#    my @result;
#    for my $unit (@units)
#    {
#        #my ($map_x, $map_y) = $self->map_xy($unit);
#        push @result, $unit if $map_x == $x and $map_y == $y;
#    }
#
#    return wantarray ?@result :\@result;
#}

sub types
{
    my ($self, $type) = @_;
    $self->{types}{$type}++ if defined $type;
    return wantarray ? %{$self->{types}} : $self->{types};
}

1;