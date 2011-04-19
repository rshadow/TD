#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use open qw(:std :utf8);
use lib qw(lib ../lib);

use Test::More tests    => 8;
use Encode              qw(encode_utf8 decode_utf8);

BEGIN {
    my $builder = Test::More->builder;
    binmode $builder->output,         ':encoding(UTF-8)';
    binmode $builder->failure_output, ':encoding(UTF-8)';
    binmode $builder->todo_output,    ':encoding(UTF-8)';

    note "*** Test SDLx::Widget::Button ***";
    use_ok 'SDL';
    use_ok 'SDL::Event';
    use_ok 'SDL::Rect';
    use_ok 'SDLx::App';
    use_ok 'SDLx::Widget::Button';
    use_ok 'SDLx::Surface';
    use_ok 'SDL::Color';
}

# Create App
my $app = SDLx::App->new(
    width   => 640,
    height  => 480,
);
$app->draw_rect([0,0,640,480],   0x333333FF);

# Create button surface
my $surface = SDLx::Surface->new(width => 10*100, height => 600);

# Fill button surface and make sequences
my $color_from = 128;
my %sequences;
for(my $i = 0; $i < 10; $i ++ )
{
    my $color = $color_from + $i * 8;
    $surface->draw_rect([100 * $i,0,  100,100], SDL::Color->new($color, 0, 0));
    $surface->draw_rect([100 * $i,100,100,100], SDL::Color->new(0, $color, 0));
    $surface->draw_rect([100 * $i,200,100,100], SDL::Color->new(0, 0, $color));
    $surface->draw_rect([100 * $i,300,100,100], SDL::Color->new($color, 0, $color));
    $surface->draw_rect([100 * $i,400,100,100], SDL::Color->new($color, $color, $color));
    $surface->draw_rect([100 * $i,500,100,100], 0x666666FF);

    push @{$sequences{over}},   [100 * $i,   0];
    push @{$sequences{out}},    [100 * $i, 100];
    push @{$sequences{down}},   [100 * $i, 200];
    push @{$sequences{up}},     [100 * $i, 300];
    push @{$sequences{d_over}}, [100 * $i, 400];
    push @{$sequences{d_out}},  [100 * $i, 500];
}

# Create button
my $button = SDLx::Widget::Button->new(
    surface     => $surface,
    step_x      => 1,
    step_y      => 1,
    sequences   => \%sequences,
    rect        => SDL::Rect->new(0,0,100,100),
    ticks_per_frame => 4,
    type        => 'reverse',
    sequence    => 'out',

    disable     => 0,
    app         => $app,
    parent      => $app,

    text        => SDLx::Text->new(
        font    => '/usr/share/fonts/truetype/freefont/FreeSans.ttf',
        size    => 12,
        color   => 0xFFFFFFFF,
        mode    => 'utf8',
        h_align => 'left',
        text    => 'button',
    ),
    sub {
        my ($self) = @_;
        $self->text->text( 'PRESSED!' );
    }
);
ok $button, 'created';
$button->start;
$button->show;

note 'Run app too see results';

## Add application handlers and run application
$app->add_event_handler( sub{
    my ($event, $application) = @_;
    exit if $event->type eq SDL_QUIT;
#    $button->event( $event, $app );
});
#
$app->add_show_handler( sub{
    my ($delta, $application) = @_;
#    $button->text->text( $button->sequence );
#    $button->draw;
    $app->flip;
});

$app->run;
