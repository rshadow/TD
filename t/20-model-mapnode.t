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

    note "************* Game::TD::Model::MapNode *************";

    use_ok 'Game::TD::Model::MapNode';
}


my $node = Game::TD::Model::MapNode->new(type => 'glade');
ok $node, 'Node loaded';
