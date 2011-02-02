use strict;
use warnings;
use utf8;

package Game::TD::View;

use Carp;
use SDL;
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

    die 'Missing required param "app"'   unless defined $opts{app};
    die 'Missing required param "model"' unless defined $opts{model};

    my $self = bless \%opts, $class;

    $self->_init;

    return $self;
}

sub _init
{
    my $self = shift;

    $self->font(fps => SDL::TTFont->new(
        -name => config->param('common'=>'fps'=>'font'),
        -size => config->param('common'=>'fps'=>'size'),
        -mode => SDL::UTF8_SOLID,
        -fg   => SDL::Color->new( config->color('common'=>'fps'=>'color') ),
    ));
}

sub _init_background
{
    my ($self, $conf) = @_;

    croak 'Missing required parameter "conf"' unless defined $conf;

    # Load background image from file
    $self->img( background => SDL::Surface->new(
        -name   => config->param($conf=>'background'=>'file'),
        -flags  => SDL_HWSURFACE
    ));
    $self->img('background')->display_format;
    # Image size
    $self->size(background => SDL::Rect->new(
        -width  => $self->img('background')->width,
        -height => $self->img('background')->height
    ));
    # Draw destination - all window
    $self->dest(background => SDL::Rect->new(
        -left   => 0,
        -top    => 0,
        -width  => config->param('common'=>'window'=>'width'),
        -height => config->param('common'=>'window'=>'height')
    ));
}

=head2

Draw FPS if it`s enabled in config file

=cut

sub draw_fps
{
    my ($self, $fps) = @_;

    return unless defined $fps;
    return unless config->param(user => 'showfps');

    $self->font('fps')->print(
        $self->app,
        config->param('common'=>'fps'=>'left'),
        config->param('common'=>'fps'=>'top'),
        sprintf '%d fps', $fps );
}

sub app         {return shift()->{app}}
sub model       {return shift()->{model}}

sub font
{
    my ($self, $name, $value) = @_;

    die 'Name required'             unless defined $name;
    $self->{font}{$name} = $value   if defined $value;
    return $self->{font}{$name};
}

sub img
{
    my ($self, $name, $value) = @_;

    die 'Name required'             unless defined $name;
    $self->{img}{$name} = $value    if defined $value;
    return $self->{img}{$name};
}

sub size
{
    my ($self, $name, $value) = @_;

    die 'Name required'             unless defined $name;
    $self->{size}{$name} = $value   if defined $value;
    return $self->{size}{$name};
}

sub dest
{
    my ($self, $name, $value) = @_;

    die 'Name required'             unless defined $name;
    $self->{dest}{$name} = $value   if defined $value;
    return $self->{dest}{$name};
}

=head2 conf

Return config part name by view package name

=cut

sub conf
{
    my $self = shift;
    my $pkg = caller;
    my ($conf) = $pkg =~ m/^Game::TD::View::(.*?)$/;
    $conf = lc $conf;
    return $conf;
}

1;