#!/usr/bin/perl

=head1 sdlx_widget_button.t

Тест SDLx::Widget::Button

=cut

use warnings;
use strict;
use utf8;
use open qw(:std :utf8);
use lib qw(lib ../lib);

use Test::More tests    => 2;
use Encode              qw(encode_utf8 decode_utf8);

################################################################################
# Тест подключений
################################################################################

BEGIN {
    # Подготовка объекта тестирования для работы с utf8
    my $builder = Test::More->builder;
    binmode $builder->output,         ':encoding(UTF-8)';
    binmode $builder->failure_output, ':encoding(UTF-8)';
    binmode $builder->todo_output,    ':encoding(UTF-8)';

    note "*** Тест SDLx::Widget::Button ***";
    use_ok 'SDL';
    use_ok 'SDL::Event';
    use_ok 'SDL::Rect';
    use_ok 'SDLx::App';
    use_ok 'SDLx::Widget::Button';
    use_ok 'SDLx::Surface';
}

################################################################################
# Тесты
################################################################################
my $app = SDLx::App->new();

my $surface = SDLx::Surface->new(width => 600, height => 100);
$surface->draw_rect([0,0,100,100],   0xFF0000FF);
$surface->draw_rect([100,0,100,100], 0x00FF00FF);
$surface->draw_rect([200,0,100,100], 0x0000FFFF);
$surface->draw_rect([300,0,100,100], 0xFFFF00FF);
$surface->draw_rect([400,0,100,100], 0x999999FF);
$surface->draw_rect([500,0,100,100], 0x666666FF);

# Проверим нормальное создание объекта
my $button = SDLx::Widget::Button->new(
    surface     => $surface,
    step_x      => 100,
    step_y      => 100,
#    sequences   => {
#        over    => [[0,0]],
#        out     => [[100,0]],
#        down    => [[200,0]],
#        up      => [[300,0]],
#        d_over  => [[400,0]],
#        d_out   => [[500,0]],
#    },
    rect        => SDL::Rect->new(300,300,100,100),
#    clip        => SDL::Rect->new(0,0,100,100),
    parent      => $app,
#    width       => 100,
#    height      => 100,
    ticks_per_frame => 25,
    type        => 'circular',
    sequence    => 'out',
);

note explain $button;
$button->start;
ok $button, 'created';

note 'Run app too see results';

$app->add_event_handler( sub{
    my ($event, $application) = @_;
    exit if $event->type eq SDL_QUIT;
    $button->event( $event, $app );
});

$app->add_show_handler( sub{
    my ($delta, $application) = @_;
    $surface->blit( $app );
    $button->draw($app);
    $app->flip;
});

$app->run;
