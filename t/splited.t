#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use open qw(:std :utf8);
use lib qw(lib ../lib);

use Test::More tests    => 2;
use Encode              qw(encode_utf8 decode_utf8);

BEGIN {
    my $builder = Test::More->builder;
    binmode $builder->output,         ':encoding(UTF-8)';
    binmode $builder->failure_output, ':encoding(UTF-8)';
    binmode $builder->todo_output,    ':encoding(UTF-8)';

    note "*** Тест SDLx::Sprite::Splited ***";
    use_ok 'SDL';
    use_ok 'SDL::Event';
    use_ok 'SDL::Rect';
    use_ok 'SDLx::App';
    use_ok 'SDLx::Surface';
    use_ok 'SDLx::Sprite::Splited';
    use_ok 'SDL::GFX::Rotozoom';
}

my %animation = (
    left   => [
        '/home/rubin/workspace/td/data/img/game/units/ambusher/ambusher-se-run1.png',
        '/home/rubin/workspace/td/data/img/game/units/ambusher/ambusher-se-run2.png',
    ],
    up             => [
        '/home/rubin/workspace/td/data/img/game/units/ambusher/ambusher-se-run1.png',
        '/home/rubin/workspace/td/data/img/game/units/ambusher/ambusher-se-run2.png',
    ],
    down   => [
        '/home/rubin/workspace/td/data/img/game/units/ambusher/ambusher-se-run1.png',
        '/home/rubin/workspace/td/data/img/game/units/ambusher/ambusher-se-run2.png',
    ],
    right  => [
        '/home/rubin/workspace/td/data/img/game/units/ambusher/ambusher-se-run1.png',
        '/home/rubin/workspace/td/data/img/game/units/ambusher/ambusher-se-run2.png',
        '/home/rubin/workspace/td/data/img/game/units/ambusher/ambusher-se-run3.png',
        '/home/rubin/workspace/td/data/img/game/units/ambusher/ambusher-se-run4.png',
        '/home/rubin/workspace/td/data/img/game/units/ambusher/ambusher-se-run5.png',
        '/home/rubin/workspace/td/data/img/game/units/ambusher/ambusher-se-run6.png',
        '/home/rubin/workspace/td/data/img/game/units/ambusher/ambusher-se-run7.png',
        '/home/rubin/workspace/td/data/img/game/units/ambusher/ambusher-se-run8.png',
        '/home/rubin/workspace/td/data/img/game/units/ambusher/ambusher-se-run9.png',
        '/home/rubin/workspace/td/data/img/game/units/ambusher/ambusher-se-run10.png',
        '/home/rubin/workspace/td/data/img/game/units/ambusher/ambusher-se-run11.png',
        '/home/rubin/workspace/td/data/img/game/units/ambusher/ambusher-se-run12.png',
    ],
);


# Create App
my $app = SDLx::App->new(
    width   => 1024,
    height  => 1024,
    exit_on_quit => 1,
    delay   => 100,
);

my $dst_ani1 = SDL::Rect->new(50,150,100,100);
my $spl1 = SDLx::Sprite::Splited->new(
    x       => $dst_ani1->x,
    y       => $dst_ani1->y,
    image   => $animation{right},
);
ok $spl1, 'Object created';
$spl1->start;

my $dst_ani2 = SDL::Rect->new(50,600,100,100);
my $spl2 = SDLx::Sprite::Splited->new(
    x           => $dst_ani2->x,
    y           => $dst_ani2->y,
    sequence    => 'right',
    image       => \%animation,
    type        => 'circular',
);
ok $spl2, 'Object created';
$spl2->start;

my $dst_ani3 = SDL::Rect->new(50,850,100,100);
my $spl3 = SDLx::Sprite::Splited->new(
    x       => $dst_ani3->x,
    y       => $dst_ani3->y,
    image   => $animation{right},
    transform => sub {
        my $surface = shift;
        my $rotated = SDL::GFX::Rotozoom::surface_xy(
            $surface->surface, 0, -1, 1, SMOOTHING_OFF );
        return SDLx::Surface->new(surface => $rotated);
    },
);
ok $spl3, 'Object created';
$spl3->start;



my $dst1 = SDL::Rect->new(50, 50,$spl1->w, $spl1->h);
my $dst2 = SDL::Rect->new(50,300,$spl2->w, $spl2->h);
my $dst3 = SDL::Rect->new(50,750,$spl3->w, $spl3->h);

# Run application
$app->add_show_handler(sub{

    $app->draw_rect($dst1, 0x660000FF);
    $spl1->surface->blit($app, undef, $dst1);

    $app->draw_rect($dst_ani1, 0x660000FF);
    $spl1->draw($app);

    $app->draw_rect($dst2, 0x006600FF);
    $spl2->surface->blit($app, undef, $dst2);

    $app->draw_rect($dst_ani2, 0x006600FF);
    $spl2->draw($app);

    $app->draw_rect($dst3, 0x000066FF);
    $spl3->surface->blit($app, undef, $dst3);

    $app->draw_rect($dst_ani3, 0x000066FF);
    $spl3->draw($app);

    $app->flip;
});

$app->run;
