use strict;
use warnings;
use utf8;

package Game::TD::View;

use Carp;
#use SDL;
use SDLx::Sprite;
use SDLx::Text;

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

    $self->font(fps => SDLx::Text->new(
        font    => config->param('common'=>'fps'=>'font'),
        size    => config->param('common'=>'fps'=>'size'),
        color   => config->color('common'=>'fps'=>'color'),
    ));

    $self->dest(fps => SDL::Rect->new(
        config->param('common'=>'fps'=>'left'),
        config->param('common'=>'fps'=>'top'),
        0, 0
    ));
}

sub _init_background
{
    my ($self, $conf) = @_;

    # Load background image from file
    $self->sprite(background => SDLx::Sprite->new(
        image   => config->param($self->conf=>'background'=>'file')
    ));
#    $self->img->load(config->param($conf=>'background'=>'file'));
     $self->sprite('background')->draw( $self->app );

#    $self->sprite( background => SDL::Surface->new(
#        -name   => config->param($conf=>'background'=>'file'),
#        -flags  => SDL_HWSURFACE,
#    ));
#    $self->sprite('background')->display_format;
    # Image size
#    $self->size(background => SDL::Rect->new(
#        -width  => $self->sprite('background')->width,
#        -height => $self->sprite('background')->height
#    ));
#    # Draw destination - all window
#    $self->dest(background => SDL::Rect->new(
#        -left   => 0,
#        -top    => 0,
#        -width  => config->param('common'=>'window'=>'width'),
#        -height => config->param('common'=>'window'=>'height')
#    ));

#    $self->sprite('background')->blit(
#        $self->size('background'), $self->app, $self->dest('background'));
}

=head2

Draw FPS if it`s enabled in config file

=cut

sub draw_fps
{
    my ($self, $fps) = @_;

    return unless defined $fps;

#    $self->sprite('background')->clip($x,$y,$w,$h);
#    $self->sprite('background')->draw();

    $self->font('fps')->text(sprintf '%d fps', $fps);
    $self->font('fps')->write_xy(
        $self->app,
        config->param('common'=>'fps'=>'left'),
        config->param('common'=>'fps'=>'top')
    );

#    $self->font('fps')->draw($self->dest('fps'));
#    $self->font('fps')->write_to(
#        $self->dest('fps'),
#    );

#    my $str = sprintf '%d fps', $fps;
#
#    $self->sprite('background')->blit(
#        $self->size('fps'), $self->app, $self->dest('fps'));
#
#    $self->font('fps')->print(
#        $self->app,
#        $self->dest('fps')->left,
#        $self->dest('fps')->top,
#        $str
#    );
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

sub sprite
{
    my ($self, $name, $value) = @_;

    die 'Name required'                 unless defined $name;
    $self->{sprite}{$name} = $value     if defined $value;
    return $self->{sprite}{$name};
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
    my ($conf) = $pkg =~ m/^Game::TD::View::State::(.*?)$/;
    $conf = lc $conf;
    return $conf;
}

1;