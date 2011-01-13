use strict;
use warnings;
use utf8;

package Game::TD::View;

use SDL::TTFont;

use Game::TD::Config;

=head1 Game::TD::View

View for TD game

=cut

=head1 Функции

=cut

=head2 new HASH

Конструктор

=head3 Входные параметры

=head4 параметр

=cut

sub new
{
    my ($class, %opts) = @_;

    die 'Missing required param "app"' unless defined $opts{app};

    my $self = bless \%opts, $class;

    $self->_init;

    return $self;
}

sub _init
{
    my $self = shift;

    $self->{font}{fps} = SDL::TTFont->new(
        -name => "/usr/share/fonts/truetype/msttcorefonts/Verdana.ttf",
        -size => '12',
        -mode => SDL::UTF8_SOLID,
        -fg     => $SDL::Color::red,
    );

    $self->{font}{debug} = SDL::TTFont->new(
        -name => "/usr/share/fonts/truetype/msttcorefonts/Verdana.ttf",
        -size => '12',
        -mode => SDL::UTF8_SOLID,
        -fg     => $SDL::Color::yellow,
    );
}

=head2

Draw FPS if it`s enabled in config file

=cut

sub draw_fps
{
    my ($self, $fps) = @_;

    return unless defined $fps;
    return unless config->param('showfps');

    $self->font_fps->print( $self->app, 2, 2, sprintf '%d fps', $fps );
}

sub draw
{
    die 'Parent class draw can`t bee used';
}

sub app         {return shift()->{app}}
sub font_fps    {return shift()->{font}{fps}}
sub font_debug  {return shift()->{font}{debug}}
sub intro       {return shift()->{draw}{intro}}

1;