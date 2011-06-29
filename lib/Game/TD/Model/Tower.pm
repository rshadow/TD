use strict;
use warnings;
use utf8;

package Game::TD::Model::Tower;
#use base qw(Exporter);
#our @EXPORT = qw();

use Carp;
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

    my $self = bless \%opts, $class;

    # Get from config
    my %tower = %{ config->param('tower'=>'towers'=>$self->type) || {} };
    %tower = %{ config->param('tower'=>'unknown') } unless %tower;
    # Concat
    $self->{$_} = $tower{$_} for keys %tower;

    return $self;
}

sub damage { return shift()->{damage} }
sub speed  { return shift()->{speed}  }
sub cost   { return shift()->{cost}   }
sub type   { return shift()->{type}   }
sub name   { return shift()->{name}   }
sub item   { return shift()->{item}   }

1;