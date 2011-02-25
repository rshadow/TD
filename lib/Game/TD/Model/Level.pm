use strict;
use warnings;
use utf8;

package Game::TD::Model::Level;

use Game::TD::Config;

use constant TAIL_WIDTH     => 50;
use constant TAIL_HEIGHT    => 50;

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

    die 'Missing required param "level"'    unless defined $opts{level};

    my $self = bless \%opts, $class;

    # Load level hash
    my ($file) =
        glob sprintf '%s/%d.*.level', config->dir('level'), $self->level;
    my %level = do $file;
    die $@ if $@;

    # Concat
    $self->{$_} = $level{$_} for keys %level;

    return $self;
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
    my ($self) = @_;
    die 'Missing "map" parameter in level file'
        unless defined $self->{map};
    return (wantarray) ? @{$self->{map}} :$self->{map};
}

sub map_width
{
    my ($self) = @_;
    return $#{ $self->map->[0] } + 1;
}

sub map_height
{
    my ($self) = @_;
    return $#{ $self->map } + 1;
}

sub wave
{
    my ($self) = @_;
    die 'Missing "wave" parameter in level file'
        unless defined $self->{wave};
    return (wantarray) ? @{$self->{wave}} :$self->{wave};
}

sub sleep
{
    my ($self) = @_;
    die 'Missing "sleep" parameter in level file'
        unless defined $self->{sleep};
    return $self->{sleep};
}

sub health
{
    my ($self) = @_;
    die 'Missing "health" parameter in level file'
        unless defined $self->{health};
    return $self->{health};
}

sub level       { return shift()->{level} }

=head2 tail_width

Get tail width in pixel

=cut

sub tail_width  { return TAIL_WIDTH  }

=head2 tail_height

Get tail height in pixel

=cut

sub tail_height { return TAIL_HEIGHT }

=head2 tail_map_width

Get map width in pixel

=cut

sub tail_map_width
{
    my ($self) = @_;
    return $self->map_width * $self->tail_width;
}

=head2 tail_map_height

Get map height in pixel

=cut

sub tail_map_height
{
    my ($self) = @_;
    return $self->map_height * $self->tail_height;
}

1;