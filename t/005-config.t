#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use open qw(:std :utf8);
use lib qw(lib ../lib);

use Test::More tests    => 5;

BEGIN {
    # utf-8
    my $builder = Test::More->builder;
    binmode $builder->output,         ':encoding(UTF-8)';
    binmode $builder->failure_output, ':encoding(UTF-8)';
    binmode $builder->todo_output,    ':encoding(UTF-8)';

    note "************* Game::TD::Config *************";

    use_ok 'Game::TD::Config';
}


ok config, 'Config created';
ok config->base, 'Get base dir';
ok config->dir('po') && config->dir('level') &&
   config->dir('config'),
    'All dir params';
ok defined config->param(player=>'debug'), 'All file params';

#note explain config;