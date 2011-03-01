use strict;
use warnings;
use utf8;

package Game::TD::Model::Map;

use constant TAIL_WIDTH     => 50;
use constant TAIL_HEIGHT    => 50;

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

    die 'Missing required param "map"'    unless defined $opts{map};

    my $self = bless \%opts, $class;

    # Set logical width
    $self->{width}  = scalar @{ $self->map->[0] };
    $self->{height} = scalar @{ $self->map };

    # Set pixel width
    $self->{tail_map_width}  = $self->width  * $self->tail_width;
    $self->{tail_map_height} = $self->height * $self->tail_height;

    $self->_init_tile;

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
            $self->map->[$x][$y] = Game::TD::Model::Tail->new(
                x => $x,
                y => $y,
                %{ $self->map->[$x][$y] },
            );
        }
    }

    # Find start and finish tails
    $self->start($_->{path}{name}, $_)  for $self->find_by_path_type('start');
    $self->finish($_->{path}{name}, $_) for $self->find_by_path_type('finish');
}

sub map     {return shift()->{map}}
sub width   {return shift()->{width}}
sub height  {return shift()->{height}}

sub start
{
    my ($self, $name, $tail) = @_;
    $self->{start}{$name} = $tail if defined $tail;
    return $self->{start}{$name};
}

sub finish
{
    my ($self, $name, $tail) = @_;
    $self->{finish}{$name} = $tail if defined $tail;
    return $self->{finish}{$name};
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
    return $self->map->[$x][$y];
}

=head2 tail_width

Get tail width in pixel

=cut

sub tail_width  { return TAIL_WIDTH  }

=head2 tail_height

Get tail height in pixel

=cut

sub tail_height { return TAIL_HEIGHT }

sub find_by_path_type
{
    my ($self, $type) = @_;

    my @result;

    for my $y (0 .. $self->height - 1)
    {
        for my $x (0 .. $self->width - 1)
        {
            my $tail = $self->tail($x, $y);
            push @result, $tail if $tail->has_path_type($type);
        }
    }

    return wantarray ? @result : \@result;
}

sub next_path
{
    my ($self, $name, $x, $y) = @_;

    return undef if $self->tail($x, $y)->{path}{type} eq 'finish';

    # Create array of possibles ways
    my @path = (
        ($y > 0)                    ? {x => $x,   y => $y-1}    : (),
        ($y < $self->height - 1)    ? {x => $x+1, y => $y  }    : (),
        ($x < $self->width  - 1)    ? {x => $x,   y => $y+1}    : (),
        ($x > 0)                    ? {x => $x-1, y => $y  }    : (),
    );

    die 'TODO!!!';
#    # Find next possible path
#    for my $possible (@path)
#    {
#    }
}

1;