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
    binmode $builder->output,         ':encoding(UTF-8)';
    binmode $builder->failure_output, ':encoding(UTF-8)';
    binmode $builder->todo_output,    ':encoding(UTF-8)';

    note "************* Game::TD::Model::Map *************";

    use_ok 'Game::TD::Config';
    use_ok 'Game::TD::Model::Map';
}

my ($file) = glob sprintf '%s/%d.*.level', config->dir('level'), 0;
my %level = do $file;
ok !$@, 'level loaded';

my $map = Game::TD::Model::Map->new( map => $level{map} );
ok $map, 'Map created';

$map->next_path('path1', 0, 0);