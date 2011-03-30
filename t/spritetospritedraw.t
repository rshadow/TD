#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use Test::More tests    => 2;

BEGIN {
    use_ok('SDL');
    use_ok('SDL::Event;');
    use_ok('SDLx::App');
    use_ok('SDLx::Surface');
    use_ok('SDLx::Sprite');
}

my $app = SDLx::App->new();

#my $sprite = SDLx::Sprite->new(image => '/home/rubin/pictures/bg.png');
my $sprite = SDLx::Sprite->new(width => 100, height => 100);
$sprite->surface->draw_rect( SDL::Rect->new(0,0,100,100), 0x00FF00FF );

my $another = SDLx::Sprite->new(width=>100, height=>100);
$another->surface->draw_rect( SDL::Rect->new(0,0,100,100), 0xFF0000FF );

# This is wrong!
$sprite->draw($another->surface);

$app->add_event_handler( sub{
    my ($event, $app) = @_;
    exit if $event->type eq SDL_QUIT;

});

$app->add_show_handler( sub{
    $another->draw( $app );
    $app->flip;
});

$app->run;