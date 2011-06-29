#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use open qw(:std :utf8);
use lib qw(lib ../lib);

use Test::More tests    => 1;

BEGIN {
    # utf-8
    my $builder = Test::More->builder;
    binmode $builder->output,         ":encoding(UTF-8)";
    binmode $builder->failure_output, ":encoding(UTF-8)";
    binmode $builder->todo_output,    ":encoding(UTF-8)";

    note "************* Game::TD::Notify *************";

    use_ok 'Game::TD::Notify';
}
