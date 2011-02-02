#!/usr/bin/perl

use strict;
use warnings;
use lib qw(lib);
use utf8;
use open qw(:utf8 :std);

use Game::TD;

#$::SIG{'__DIE__'} = sub {
#    use Carp;
#    confess @_;
#};

my $game = Game::TD->new;
die 'Can`t init application' unless $game;

$game->run;

exit;
