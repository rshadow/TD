#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use open qw(:std :utf8);
use lib qw(lib ../lib);

use Test::More tests    => 3;

BEGIN {
    # utf-8
    my $builder = Test::More->builder;
    binmode $builder->output,         ':encoding(UTF-8)';
    binmode $builder->failure_output, ':encoding(UTF-8)';
    binmode $builder->todo_output,    ':encoding(UTF-8)';

    note "************* Game::TD::Model::State::Menu *************";

    use_ok 'Game::TD::Model::State::Menu';
}

my $menu = Game::TD::Model::State::Menu->new();
ok $menu, 'menu loaded';
ok length $menu->items, 'menu items present';

ok length $menu->version, 'version: '.$menu->version;

#ok $menu->current == 0, 'Current top item';
#ok $menu->up   && $menu->current == 0, 'Up work';
#ok $menu->up   && $menu->current == 0, 'Up wall work';
#ok 'ARRAY' eq ref $menu->items, 'Items get';
#$menu->down for $menu->items;
#ok $menu->current == $#{$menu->items}, 'Down work';
#ok $menu->down && $menu->current == $#{$menu->items}, 'Down wall work';
