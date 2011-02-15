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
    binmode $builder->output,         ":utf8";
    binmode $builder->failure_output, ":utf8";
    binmode $builder->todo_output,    ":utf8";

    note "************* Game::TD::Config *************";

    use_ok 'Game::TD::Config';
}


ok config, 'Config created';
ok config->base, 'Base dir looks good';
ok config->dir('map') && config->dir('po') && config->dir('level') &&
   config->dir('config'),
    'All init dir params looks good';
ok defined config->param('user'=>'debug'),
    'All init file params looks good';

#note explain config;