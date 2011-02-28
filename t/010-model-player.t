#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use open qw(:std :utf8);
use lib qw(lib ../lib);

use Test::More tests    => 4;

BEGIN {
    # utf-8
    my $builder = Test::More->builder;
    binmode $builder->output,         ':encoding(UTF-8)';
    binmode $builder->failure_output, ':encoding(UTF-8)';
    binmode $builder->todo_output,    ':encoding(UTF-8)';

    note "************* Game::TD::Model::Player *************";

    use_ok 'Game::TD::Model::Player';
}


my $player = Game::TD::Model::Player->new;
ok $player, 'Player created';
ok defined $player->score && defined $player->name && defined $player->level &&
   defined $player->money && defined $player->difficult,
    'All init params looks good';

my $level = $player->level;
ok $player->levelup == $level + 1, 'Level up work';
