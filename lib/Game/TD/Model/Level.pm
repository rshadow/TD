use strict;
use warnings;
use utf8;

package Game::TD::Model::Level;

use Game::TD::Config;
use Game::TD::Model::Map;

=head1 NAME

Game::TD::Model::Level - Модуль

=head1 DESCRIPTION

=cut

=head1 METHODS

=cut

=head2 new HASH

=cut

sub new
{
    my ($class, %opts) = @_;

    die 'Missing required param "level"' unless defined $opts{level};

    my $self = bless \%opts, $class;

    # Load level hash
    my ($file) =
        glob sprintf '%s/%d.*.level', config->dir('level'), $self->level;
    my %level = do $file;
    die $@ if $@;

    # Concat
    $self = { %level, %$self };

    return $self;
}

sub level   { return shift()->{level};  }
sub name    { return shift()->{name};   }
sub title   { return shift()->{title};  }

sub map     { return shift()->{map};    }
sub wave    { return shift()->{wave};   }
sub sleep   { return shift()->{sleep};  }

1;

