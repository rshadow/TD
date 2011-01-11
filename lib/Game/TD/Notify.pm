package Game::TD::Notify;
use base qw(Exporter);
our @EXPORT = qw(notify);

use warnings;
use strict;
use utf8;

use Game::TD::Config;

=head1 NAME

Game::TD::Notify - Notification module

=head1 SYNOPSIS

  use Game::TD::Notify;

=head1 DESCRIPTION

=cut

=head1 METHODS

=cut

sub notify
{
    my ($message, @opts) = @_;

    $| = 1 unless $|;

    (@opts)
        ? print "$message\n"
        : printf "$message\n", @opts;
}

sub debug
{
    notify @_ if config->param('debug');
}

1;
