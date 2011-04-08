#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use open qw(:std :utf8);
use lib qw(lib ../lib);

use 5.10.0;

use Test::More tests    => 1;

BEGIN {
    # utf-8
    my $builder = Test::More->builder;
    binmode $builder->output,         ':encoding(UTF-8)';
    binmode $builder->failure_output, ':encoding(UTF-8)';
    binmode $builder->todo_output,    ':encoding(UTF-8)';

    note "************* Modules *************";

    use_ok 'SDL 2.530';
}
