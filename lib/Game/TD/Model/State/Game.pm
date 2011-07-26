use strict;
use warnings;
use utf8;

package Game::TD::Model::State::Game;
use base qw(Game::TD::Model);

use Carp;
use Game::TD::Config;
use Game::TD::Model::Wave;
use Game::TD::Model::Force;
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
    # Check params
    for my $param (qw(name title sleep post health cash wave map))
    {
        croak sprintf 'Missing "%s" parameter in level "%s"',
            $param, $file
                unless defined $level{$param};
    }
    # Concat
    $self->{$_} = $level{$_} for keys %level;

    # Create map
    $self->map( Game::TD::Model::Map->new(map => delete $level{map}) );

    # Create units wave
    $self->wave( Game::TD::Model::Wave->new(
        wave    => delete $level{wave},
        map     => $self->map,
        dt      => $self->dt,
    ));

    # Create player`s force pull
    $self->force(Game::TD::Model::Force->new(dt => $self->dt));

    # Create camera
    $self->camera(Game::TD::Model::Camera->new( map => $self->map ));

    # Add money
    $self->player->money($self->player->money + $self->cash);

    # Level start sleep timer
    $self->timer('sleep'=>'new');
    $self->left('sleep' => $self->sleep - $self->timer('sleep')->get_ticks);
    $self->timer('sleep')->start;
    # Level end sleep timer
    $self->timer('post'=>'new');
    $self->left('post' => $self->post - $self->timer('post')->get_ticks);

    # Units timer
    $self->timer('units'=>'new');
#    # Towers timer
#    $self->timer('tower'=>'new');

    return $self;
}

sub update
{
    my ($self, $step, $t) = @_;

    # Update camera
    $self->camera->update;

    # Start level sleep timer
    if( $self->left('sleep') )
    {
        $self->left('sleep' => $self->sleep - $self->timer('sleep')->get_ticks);
        # Stop sleep time and start units timer
        unless( $self->left('sleep') )
        {
            $self->timer('sleep')->stop;
            $self->timer('units')->start;
        }
        return 1;
    }
    # Post message timer
    elsif( $self->left('post') and $self->result('finish') )
    {
        $self->left('post' => $self->post - $self->timer('post')->get_ticks);
        # Stop post timer and exit from game state
        unless( $self->left('post') )
        {
            $self->timer('post')->stop;
            return 0;
        }

        # Just update units ... they run
        $self->wave->update( $self->timer('units')->get_ticks, $step );
        return 1;
    }

    # Update units
    my $unit_ticks = $self->timer('units')->get_ticks;
    my %result = $self->wave->update( $unit_ticks, $step );
    # Make damage if exists
    $self->{health} -= $result{damage} if exists $result{damage};

    # Update forces
#    my $tower_ticks = $self->timer('tower')->get_ticks;
    $self->force->update(
        $step,
        $self->player,
        [$self->wave->active($unit_ticks)]
    );

    # Check for level health
    if( $self->health <= 0 )
    {
        $self->result('finish' => 'failed');
    }
    # Check for complete level
    elsif( $self->wave->is_empty )
    {
        $self->timer('units')->stop;
        $self->result('finish' => 'complete');
    }

    # Notify and start post message timer
    if( $self->result('finish') )
    {
        notify('Level "%s" is %s', $self->title, $self->result('finish'));
        $self->timer('post')->start;
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

=head2 post

Return level post complete pause

=cut

sub post
{
    my ($self) = @_;
    return $self->{post};
}

=head2 left

Get/Set counter for game start. See <i>Game::TD::Model::Level::sleep</i>
function.

=cut

sub left
{
    my ($self, $name, $value) = @_;

    croak 'Missing required "name" parameter' unless defined $name;
    if( defined $value )
    {
        $self->{left}{$name} = ($value > 0) ?$value : 0;
    }
    return $self->{left}{$name};
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

=head2 cash

Return level cash

=cut

sub cash
{
    my ($self) = @_;
    die 'Missing "cash" parameter in level file'
        unless defined $self->{cash};
    return $self->{cash};
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

=head2 force $force

Get/set player`s force pull Game::TD::Model::Force

=cut

sub force
{
    my ($self, $force) = @_;
    $self->{force} = $force if defined $force;
    return $self->{force};
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

=head2 camera $camera

Get/set camera

=cut

sub camera
{
    my ($self, $camera) = @_;
    $self->{camera} = $camera if defined $camera;
    return $self->{camera};
}

1;