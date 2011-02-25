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
    binmode $builder->output,         ":utf8";
    binmode $builder->failure_output, ":utf8";
    binmode $builder->todo_output,    ":utf8";

    note "************* Game::TD::Model::Wave *************";

    use_ok 'Game::TD::Config';
    use_ok 'Game::TD::Model::Wave';
}

my ($file) = glob sprintf '%s/%d.*.level', config->dir('level'), 0;
my %level = do $file;
ok !$@, 'level loaded';

my $wave = Game::TD::Model::Wave->new( wave => $level{wave} );
ok $wave, 'Wave created';

ok defined $wave->current,  'get current: '.$wave->current;
ok $wave->waves_count,      'get waves count: '.$wave->waves_count;
ok $wave->path_count,       'get path count: '.$wave->path_count;
