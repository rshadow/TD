use strict;
use warnings;
use utf8;

package Game::TD::Model::Map;

use constant TAIL_WIDTH     => 50;
use constant TAIL_HEIGHT    => 50;

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

    # Set logigal width
    $self->{width}  = scalar @{ $self->map->[0] };
    $self->{height} = scalar @{ $self->map };

    # Set pixel width
    $self->{tail_map_width}  = $self->width * $self->tail_width;
    $self->{tail_map_height} = $self->height * $self->tail_height;

    return $self;
}

sub map     {return shift()->{map}}
sub width   {return shift()->{width}}
sub height  {return shift()->{height}}

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

1;