#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use open qw(:std :utf8);
use lib qw(lib ../lib);

use Test::More tests    => 2;

BEGIN {
    # utf-8
    my $builder = Test::More->builder;
    binmode $builder->output,         ":utf8";
    binmode $builder->failure_output, ":utf8";
    binmode $builder->todo_output,    ":utf8";

    note "************* Game::TD::Model::Map *************";

    use_ok 'Game::TD::Model::Map';
}


my $map = Game::TD::Model::Map->new(name => 1);
ok $map, 'Map loaded';

#note explain $map;