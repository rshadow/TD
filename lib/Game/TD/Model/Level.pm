use strict;
use warnings;
use utf8;

package Game::TD::Model::Level;
use base qw(Game::TD::Model);

use Carp;
use Game::TD::Config;
#use Game::TD::Model::Wave;
use Game::TD::Model::Map;
use Game::TD::Model::Unit;

=head1 Game::TD::Model::Level

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

    die 'Missing required param "num"'    unless defined $opts{num};

    my $self = $class->SUPER::new(%opts);

    # Load level hash
    my ($file) =
        glob sprintf '%s/%d.*.level', config->dir('level'), $self->num;
    my %level = do $file;
    die $@ if $@;

    die 'Missing "map" parameter in level file' unless defined $level{map};
    $self->map( Game::TD::Model::Map->new(map => delete $level{map}) );

    # Concat
    $self->{$_} = $level{$_} for keys %level;

    # Init units positions
    $self->_init_units;

    $self->timer('sleep'=>'new');
    $self->left( $self->sleep - $self->timer('sleep')->get_ticks );
    $self->timer('sleep')->start;

    return $self;
}

sub _init_units
{
    my ($self) = @_;

    my @path = keys %{ $self->wave };

    for my $path ( @path )
    {
        my $tail = $self->map->start($path);

        for my $rec ( @{ $self->{wave}{$path} } )
        {
            $rec = Game::TD::Model::Unit->new(
                type        => $rec->{unit},
                x           => $tail->x * $self->map->tail_width,
                y           => $tail->y * $self->map->tail_height,
                direction   => 'right',
                span        => $rec->{span},
            );
        }
    }
}

sub update
{
    my ($self) = @_;

    # Sleep timer
    if( $self->left)
    {
        $self->left( $self->sleep - $self->timer('sleep')->get_ticks );
        return 1;
    }

#    my @units = $self->get_active_units;

}

sub name
{
    my ($self) = @_;
    die 'Missing "name" parameter in level file'
        unless defined $self->{name};
    return $self->{name};
}

sub title
{
    my ($self) = @_;
    die 'Missing "title" parameter in level file'
        unless defined $self->{title};
    return $self->{title};
}

sub map
{
    my ($self, $map) = @_;
    $self->{map} = $map if defined $map;
    return $self->{map};
}

sub wave
{
    my ($self, $wave) = @_;
    return wantarray ? %{$self->{wave}} : $self->{wave};
}

sub sleep
{
    my ($self) = @_;
    die 'Missing "sleep" parameter in level file'
        unless defined $self->{sleep};
    return $self->{sleep};
}

=head2 left

Get/Set counter for game start. See <i>Game::TD::Model::Level::sleep</i>
function.

=cut

sub left
{
    my ($self, $value) = @_;
    if( defined $value )
    {
        $self->{left} = ($value > 0) ?$value : 0;
    }
    return $self->{left};
}

sub health
{
    my ($self) = @_;
    die 'Missing "health" parameter in level file'
        unless defined $self->{health};
    return $self->{health};
}

sub num       { return shift()->{num}   }

sub get_active_units
{
    my ($self) = @_;

    # Run timer if not exists
    $self->timer('units' => 'new')->start unless $self->timer('units');

#    my @active = grep {}
    $self->timer('units')->get_ticks;
}
1;