use strict;
use warnings;
use utf8;

package Game::TD::Model::Tower;
#use base qw(Exporter);
#our @EXPORT = qw();

use Carp;
use Scalar::Util qw(weaken);
use Game::TD::Config;

=head1 Game::TD::Model::Tower

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

    croak 'Missing required param "type"'   unless defined $opts{type};
    croak 'Missing required param "name"'   unless defined $opts{name};
    croak 'Missing required param "tile"'   unless defined $opts{tile};

    weaken $opts{tile};

    my $self = bless \%opts, $class;

    # Get from config
    my %tower = %{ config->param('tower'=>'towers'=>$self->type) || {} };
    %tower = %{ config->param('tower'=>'unknown') } unless %tower;
    # Concat
    $self->{$_} = $tower{$_} for keys %tower;

    # Tower already done
    $self->prepare(0);

    return $self;
}

sub damage { return shift()->{damage} }
sub speed  { return shift()->{speed}  }
sub cost   { return shift()->{cost}   }
sub type   { return shift()->{type}   }
sub name   { return shift()->{name}   }
sub item   { return shift()->{item}   }
sub range  { return shift()->{range}  }
sub tile   { return shift()->{tile}   }

=head2 prepare $prepare

Set/get time to next shot

=cut

sub prepare
{
    my ($self, $prepare) = @_;
    $self->{prepare} = $prepare if defined $prepare;
    return $self->{prepare};
}

sub preparing
{
    my ($self, $step) = @_;

    # Skip if ready
    return 0 unless $self->prepare;

    # Calculate preparing time
    ($self->prepare > $step)
        ? $self->prepare( $self->prepare - $step )
        : $self->prepare( 0 );

    return ($self->prepare) ?1 :0;
}

1;