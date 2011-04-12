use strict;
use warnings;
use utf8;

package Game::TD::Model::Map;

use Carp;
use Game::TD::Model::Tail;

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
    $self->{tail_map_width}  = $self->width  * $self->tail_width;
    $self->{tail_map_height} = $self->height * $self->tail_height;

    $self->_init_tile;
    $self->_init_roads;

    return $self;
}

sub _init_tile
{
    my ($self) = @_;

    # Add coordinates in tail for simpless
    for my $y (0 .. $self->height - 1)
    {
        for my $x (0 .. $self->width - 1)
        {
            my $tile = Game::TD::Model::Tail->new(
                x => $x,
                y => $y,
                %{ $self->map->[$y][$x] },
            );
            $self->map->[$y][$x] = $tile;

            # Store types
            $self->tile_types( $tile->type,      $tile->mod      );
            $self->item_types( $tile->item_type, $tile->item_mod );
        }
    }
}

sub _init_roads
{
    my ($self) = @_;

    # Find start tails
    for my $tail ( $self->tail_find_by_path_type('start') )
    {
        for my $name ( keys %{ $tail->path } )
        {
            $self->start($name, $tail);
        }
    }
    # Find finish tails
    for my $tail ( $self->tail_find_by_path_type('finish') )
    {
        for my $name ( keys %{ $tail->path } )
        {
            $self->finish($name, $tail);
        }
    }

    # Set directions: move by road from start to end and set it for each tail
    for my $name ( keys %{$self->start} )
    {
        my $tail = $self->start($name);
        while( $tail )
        {
            if( $self->tail($tail->x-1, $tail->y)               and
               !$self->tail($tail->x-1, $tail->y)->next($name)  and
                $self->tail($tail->x-1, $tail->y)->has_path     and
                $self->tail($tail->x-1, $tail->y)->has_path_name($name) )
            {
                $tail->next($name, $self->tail($tail->x-1, $tail->y));
                $tail->direction($name, 'left');
            }
            elsif(
                $self->tail($tail->x+1, $tail->y)               and
               !$self->tail($tail->x+1, $tail->y)->next($name)  and
                $self->tail($tail->x+1, $tail->y)->has_path     and
                $self->tail($tail->x+1, $tail->y)->has_path_name($name) )
            {
                $tail->next($name, $self->tail($tail->x+1, $tail->y));
                $tail->direction($name, 'right');
            }
            elsif(
                $self->tail($tail->x, $tail->y-1)               and
               !$self->tail($tail->x, $tail->y-1)->next($name)  and
                $self->tail($tail->x, $tail->y-1)->has_path     and
                $self->tail($tail->x, $tail->y-1)->has_path_name($name) )
            {
                $tail->next($name, $self->tail($tail->x, $tail->y-1));
                $tail->direction($name, 'up');
            }
            elsif(
                $self->tail($tail->x, $tail->y+1)               and
               !$self->tail($tail->x, $tail->y+1)->next($name)  and
                $self->tail($tail->x, $tail->y+1)->has_path     and
                $self->tail($tail->x, $tail->y+1)->has_path_name($name) )
            {
                $tail->next($name, $self->tail($tail->x, $tail->y+1));
                $tail->direction($name, 'down');
            }

            # while not finish
            last if $tail->has_path_type($name, 'finish');

#            printf "%s - %s:%s",
#                join( ',', keys %{$tail->path || {}}),
#                $tail->x,
#                $tail->y;
#            print "\n";

            # Goto next tail
            $tail = $tail->next($name);
        }
    }
}

sub map     {return shift()->{map}}
sub width   {return shift()->{width}}
sub height  {return shift()->{height}}

sub start
{
    my ($self, $name, $tail) = @_;
    $self->{start}{$name} = $tail if defined $tail;
    return $self->{start}{$name}  if defined $name;
    return wantarray ?%{ $self->{start} } :$self->{start};
}

sub finish
{
    my ($self, $name, $tail) = @_;
    $self->{finish}{$name} = $tail if defined $tail;
    return $self->{finish}{$name}  if defined $name;
    return wantarray ?%{ $self->{finish} } :$self->{finish};
}

=head2 tail_map_width

Get map width in pixel

=cut

sub tail_map_width   {return shift()->{tail_map_width}}

=head2 tail_map_height

Get map height in pixel

=cut

sub tail_map_height  {return shift()->{tail_map_height}}

sub tail
{
    my ($self, $x, $y) = @_;
    return $self->map->[$y][$x];
}

=head2 tail_width

Get tail width in pixel

=cut

sub tail_width  { return TAIL_WIDTH  }

=head2 tail_height

Get tail height in pixel

=cut

sub tail_height { return TAIL_HEIGHT }

sub tail_find_by_path_type
{
    my ($self, $type) = @_;

    my @result;

    for my $y (0 .. $self->height - 1)
    {
        for my $x (0 .. $self->width - 1)
        {
            my $tail = $self->tail($x, $y);
            push @result, $tail if $tail->has_path_type(undef, $type);
        }
    }

    return wantarray ? @result : \@result;
}

sub tile_types
{
    my ($self, $type, $mod) = @_;
    $self->{tile_types}{$type}{$mod}++ if defined $type and defined $mod;
    return wantarray ? %{$self->{tile_types}} : $self->{tile_types};
}

sub item_types
{
    my ($self, $type, $mod) = @_;
    $self->{item_types}{$type}{$mod}++ if defined $type and defined $mod;
    return wantarray ? %{$self->{item_types}} : $self->{item_types};
}

1;