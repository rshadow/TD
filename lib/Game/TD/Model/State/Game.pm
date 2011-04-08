use strict;
use warnings;
use utf8;

package Game::TD::Model::State::Game;
use base qw(Game::TD::Model);

use Carp;
use Game::TD::Config;
use Game::TD::Model::Wave;
use Game::TD::Model::Map;
use Game::TD::Model::Camera;

=head1 Game::TD::Model::State::Game

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

    croak 'Missing required param "num"'    unless defined $opts{num};
    croak 'Missing required param "player"' unless defined $opts{player};
    croak 'Missing required param "dt"'     unless defined $opts{dt};

    my $self = $class->SUPER::new(%opts);

    # Load level hash
    my ($file) =
        glob sprintf '%s/%d.*.level', config->dir('level'), $self->num;
    my %level = do $file;
    die $@ if $@;

    croak 'Missing "map" parameter in level file' unless defined $level{map};
    $self->map( Game::TD::Model::Map->new(map => delete $level{map}) );

    croak 'Missing "wave" parameter in level file' unless defined $level{wave};
    $self->wave( Game::TD::Model::Wave->new(
        wave    => delete $level{wave},
        map     => $self->map,
        dt      => $self->dt,
    ));

    # Create camera
    $self->camera(Game::TD::Model::Camera->new( map => $self->map ));

    # Concat
    $self->{$_} = $level{$_} for keys %level;

    # Sleep timer
    $self->timer('sleep'=>'new');
    $self->left( $self->sleep - $self->timer('sleep')->get_ticks );
    $self->timer('sleep')->start;

    # Units timer
    $self->timer('units'=>'new');

    return $self;
}

sub update
{
    my ($self) = @_;

    # Update camera
    $self->camera->update;

    # Sleep timer
    if( $self->left)
    {
        $self->left( $self->sleep - $self->timer('sleep')->get_ticks );
        # Stop sleep time and start units timer
        unless( $self->left )
        {
            $self->timer('sleep')->stop;
            $self->timer('units')->start;
        }
        return 1;
    }

    # Update units
    my %result = $self->wave->update( $self->timer('units')->get_ticks );

    # Make damage if exists
    $self->{health} -= $result{damage} if exists $result{damage};


    # Check for level health
    if( $self->health <= 0 )
    {
        $self->timer('units')->stop;
        return 0;
    }

    return 1;
}

=head2 num

Return player storage

=cut

sub player    { return shift()->{player};   }

=head2 num

Return level board position

=cut

sub num       { return shift()->{num};   }

sub dt        { return shift()->{dt};   }

=head2 name

Return level internal name

=cut

sub name
{
    my ($self) = @_;
    die 'Missing "name" parameter in level file'
        unless defined $self->{name};
    return $self->{name};
}

=head2 title

Return level title

=cut

sub title
{
    my ($self) = @_;
    die 'Missing "title" parameter in level file'
        unless defined $self->{title};
    return $self->{title};
}

=head2 sleep

Return level sleep pause before units run

=cut

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

=head2 health

Return level health

=cut

sub health
{
    my ($self) = @_;
    die 'Missing "health" parameter in level file'
        unless defined $self->{health};
    return $self->{health};
}

=head2 wave $wave

Get/set units wave storage Game::TD::Model::Wave

=cut

sub wave
{
    my ($self, $wave) = @_;
    $self->{wave} = $wave if defined $wave;
    return $self->{wave};
}

=head2 map $map

Get/set level map storage Game::TD::Model::Map

=cut

sub map
{
    my ($self, $map) = @_;
    $self->{map} = $map if defined $map;
    return $self->{map};
}

sub camera
{
    my ($self, $camera) = @_;
    $self->{camera} = $camera if defined $camera;
    return $self->{camera};
}

1;