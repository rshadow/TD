#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use open qw(:std :utf8);
use lib qw(lib ../lib);

use Test::More tests    => 8;

BEGIN {
    # utf-8
    my $builder = Test::More->builder;
    binmode $builder->output,         ":utf8";
    binmode $builder->failure_output, ":utf8";
    binmode $builder->todo_output,    ":utf8";

    note "************* Game::TD::Model::State::Intro *************";

    use_ok 'Game::TD::Model::State::Intro';
}



my $model = Game::TD::Model::State::Intro->new;
ok $model, 'Object created';
ok $model->last > 0 && $model->last > $model->current, 'Last frame init';
ok $model->delta > 0, 'Delta init';

my $current = $model->current;
ok $current == 0, 'Current frame init';
my $result = $model->update;
ok $model->current > $current, 'Update frame';
ok(( ($result > 0  && $model->last > $model->current) or
   ($result == 0 && $model->last <= $model->current)), 'Update result');
$result = $model->update for 0 .. 256;
ok $result == 0, 'Update stop';
