use strict;
use warnings;
use utf8;

package Game::TD::Model::Map;

use Carp;
use Game::TD::Model::Tile;

use Game::TD::Config;

=head1 Game::TD::Model::Map

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

    croak 'Missing required param "map"'    unless defined $opts{map};

    my $self = bless \%opts, $class;

    # Set logical width
    $self->{width}  = scalar @{ $self->map->[0] };
    $self->{height} = scalar @{ $self->map };

    # Set pixel width
    $self->{tile_map_width}  = $self->width  * $self->tile_width;
    $self->{tile_map_height} = $self->height * $self->tile_height;

    $self->_init_tile;
    $self->_init_roads;

    return $self;
}

sub _init_tile
{
    my ($self) = @_;

    # Add coordinates in tile for simpless
    for my $y (0 .. $self->height - 1)
    {
        for my $x (0 .. $self->width - 1)
        {
            my $tile = $self->map->[$y][$x];
            $tile = Game::TD::Model::Tile->new(
                x => $x,
                y => $y,
                %$tile,

            );
            $self->map->[$y][$x] = $tile;

            # Cache tile types
            $self->tile_types( $tile->type,      $tile->mod      );
            # Cache item types
            $self->item_types( $tile->item_type, $tile->item_mod )
                if $tile->has_item
        }
    }
}

sub _init_roads
{
    my ($self) = @_;

    # Find start tiles
    for my $tile ( $self->tile_find_by_path_type('start') )
    {
        for my $name ( keys %{ $tile->path } )
        {
            $self->start($name, $tile);
        }
    }
    # Find finish tiles
    for my $tile ( $self->tile_find_by_path_type('finish') )
    {
        for my $name ( keys %{ $tile->path } )
        {
            $self->finish($name, $tile);
        }
    }

    # Set directions: move by road from start to end and set it for each tile
    for my $name ( keys %{$self->start} )
    {
        my $tile = $self->start($name);
        while( $tile )
        {
            if( $self->tile($tile->x-1, $tile->y)               and
               !$self->tile($tile->x-1, $tile->y)->next($name)  and
                $self->tile($tile->x-1, $tile->y)->has_path     and
                $self->tile($tile->x-1, $tile->y)->has_path_name($name) )
            {
                $tile->next($name, $self->tile($tile->x-1, $tile->y));
                $tile->direction($name, 'left');
            }
            elsif(
                $self->tile($tile->x+1, $tile->y)               and
               !$self->tile($tile->x+1, $tile->y)->next($name)  and
                $self->tile($tile->x+1, $tile->y)->has_path     and
                $self->tile($tile->x+1, $tile->y)->has_path_name($name) )
            {
                $tile->next($name, $self->tile($tile->x+1, $tile->y));
                $tile->direction($name, 'right');
            }
            elsif(
                $self->tile($tile->x, $tile->y-1)               and
               !$self->tile($tile->x, $tile->y-1)->next($name)  and
                $self->tile($tile->x, $tile->y-1)->has_path     and
                $self->tile($tile->x, $tile->y-1)->has_path_name($name) )
            {
                $tile->next($name, $self->tile($tile->x, $tile->y-1));
                $tile->direction($name, 'up');
            }
            elsif(
                $self->tile($tile->x, $tile->y+1)               and
               !$self->tile($tile->x, $tile->y+1)->next($name)  and
                $self->tile($tile->x, $tile->y+1)->has_path     and
                $self->tile($tile->x, $tile->y+1)->has_path_name($name) )
            {
                $tile->next($name, $self->tile($tile->x, $tile->y+1));
                $tile->direction($name, 'down');
            }

            # while not finish
            last if $tile->has_path_type($name, 'finish');

#            printf "%s - %s:%s",
#                join( ',', keys %{$tile->path || {}}),
#                $tile->x,
#                $tile->y;
#            print "\n";

            # Goto next tile
            $tile = $tile->next($name);
        }
    }
}

sub map     {return shift()->{map}}
sub width   {return shift()->{width}}
sub height  {return shift()->{height}}

sub start
{
    my ($self, $name, $tile) = @_;
    $self->{start}{$name} = $tile if defined $tile;
    return $self->{start}{$name}  if defined $name;
    return wantarray ?%{ $self->{start} } :$self->{start};
}

sub finish
{
    my ($self, $name, $tile) = @_;
    $self->{finish}{$name} = $tile if defined $tile;
    return $self->{finish}{$name}  if defined $name;
    return wantarray ?%{ $self->{finish} } :$self->{finish};
}

=head2 tile_map_width

Get map width in pixel

=cut

sub tile_map_width   {return shift()->{tile_map_width}}

=head2 tile_map_height

Get map height in pixel

=cut

sub tile_map_height  {return shift()->{tile_map_height}}

sub tile
{
    my ($self, $x, $y) = @_;
    return $self->map->[$y][$x];
}

=head2 tile_width

Get tile width in pixel

=cut

sub tile_width  { return TILE_WIDTH  }

=head2 tile_height

Get tile height in pixel

=cut

sub tile_height { return TILE_HEIGHT }

sub tile_find_by_path_type
{
    my ($self, $type) = @_;

    my @result;

    for my $y (0 .. $self->height - 1)
    {
        for my $x (0 .. $self->width - 1)
        {
            my $tile = $self->tile($x, $y);
            push @result, $tile if $tile->has_path_type(undef, $type);
        }
    }

    return wantarray ? @result : \@result;
}

sub tile_types
{
    my ($self, $type, $mod) = @_;
    $self->{tile}{types}{$type}{$mod}++ if defined $type and defined $mod;
    return wantarray ? %{$self->{tile}{types}} : $self->{tile}{types};
}

sub item_types
{
    my ($self, $type, $mod) = @_;
    $self->{item}{types}{$type}{$mod}++ if defined $type and defined $mod;
    return wantarray ? %{$self->{item}{types}} : $self->{item}{types};
}

=head2 xy2map $x, $y, $direction

Get logical x and y on map for coordinates $x,$y. For units you can use
correction for direction

=cut

sub xy2map
{
    my ($self, $x, $y, $direction) = @_;

    $direction //= '';

    my $map_x = int( $x / $self->tile_width  );
    my $map_y = int( $y / $self->tile_height );

    my $tile_x = $map_x * $self->tile_width;
    my $tile_y = $map_y * $self->tile_height;

    if($direction eq 'up')
    {
        $map_y += 1 if $y > $tile_y;
    }
    elsif($direction eq 'left')
    {
        $map_x += 1 if $x > $tile_x;
    }

    return ($map_x, $map_y);
}

sub build
{
    my ($self, $x, $y, $name) = @_;

    $self->tile($x, $y)->item_add('tower' => $name);
}
1;