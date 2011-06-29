use strict;
use warnings;
use utf8;

package Game::TD::Model::Tile;
use base qw(Exporter);
our @EXPORT = qw(TILE_WIDTH TILE_HEIGHT);

use Carp;
use Scalar::Util qw(weaken);

use constant TILE_WIDTH     => 50;
use constant TILE_HEIGHT    => 50;

=head1 Game::TD::Model::Tile

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

    my $self = bless \%opts, $class;

    return $self;
}

sub x       { return shift()->{x}    }
sub y       { return shift()->{y}    }
sub type    { return shift()->{type} }
sub mod     { return shift()->{mod}  }

sub has_item
{
    my ($self) = @_;
    return exists $self->{item} ? 1 : 0;
}

sub item_type
{
    my ($self) = @_;
    return unless exists $self->{item};
    return unless exists $self->{item}{type};

    return $self->{item}{type};
}

sub item_mod
{
    my ($self) = @_;
    return unless exists $self->{item};
    return unless exists $self->{item}{mod};

    return $self->{item}{mod};
}

sub item_add
{
    my ($self, $type, $mod) = @_;

    die sprintf 'Tile %d:%d already have item', $self->x, $self->y
         if exists $self->{item};

    $self->{item}{type} = $type;
    $self->{item}{mod}  = $mod;
}

sub path
{
    my ($self) = @_;
    return unless exists $self->{path};
    return wantarray ? %{$self->{path}} : $self->{path};
}

sub has_path
{
    my ($self) = @_;
    return exists $self->{path} ? 1 : 0;
}

sub has_path_name
{
    my ($self, $path) = @_;

    return 0 unless exists $self->{path};
    return 1 if exists $self->{path}{$path};

    return 0;
}

sub has_path_type
{
    my ($self, $path, $type) = @_;

    return 0 unless exists $self->{path};

    # If defined path then check type for this path
    if(defined $path)
    {
        return 0 unless exists $self->{path}{$path};
        return 1 if exists $self->{path}{$path}{$type};
        return 0;
    }

    # If path not defined then search for type in all paths
    for my $key ( keys %{ $self->{path} } )
    {
        return 1 if exists $self->{path}{$key}{type} and
                    $type eq $self->{path}{$key}{type};
    }

    return 0;
}

sub direction
{
    my ($self, $path, $direction) = @_;

    confess 'Path name not set'   unless defined $path;

    $self->{direction}{$path} = $direction if defined $direction;
    return $self->{direction}{$path};
}

sub next
{
    my ($self, $path, $tile) = @_;

    confess 'Path name not set'   unless defined $path;

    if( defined $tile )
    {
        $self->{next}{$path} = $tile ;
        weaken $self->{next}{$path};
    }
    return $self->{next}{$path};
}


1;