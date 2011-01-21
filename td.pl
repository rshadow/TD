#!/usr/bin/perl

use strict;
use warnings;
use lib qw(lib);
use utf8;
use open qw(:utf8 :std);

use Game::TD;

my $game = Game::TD->new;
die 'Can`t init application' unless $game;

$game->run;
