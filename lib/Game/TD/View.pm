use strict;
use warnings;
use utf8;

package Game::TD::View;

use Carp;

use SDL;
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

    $self->_init_editor if config->param('editor'=>'enable');

    return $self;
}

sub _init
{
    my $self = shift;

    # Load FPS font params
    $self->font(fps => SDLx::Text->new(
        font    => config->param('common'=>'fps'=>'font'),
        size    => config->param('common'=>'fps'=>'size'),
        color   => config->color('common'=>'fps'=>'color'),
        mode    => 'utf8',
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

    # Clear background
    $self->app->draw_rect(
        SDL::Rect->new(0, 0, $self->app->w, $self->app->h),
        0x000000FF
    );

    # Load background image from file
    $self->sprite(background => SDLx::Sprite->new(
        image   => config->param($self->conf(caller)=>'background'=>'file')
    ));

    # Draw background
    $self->sprite('background')->draw( $self->app );
}

sub _init_editor
{
    my $self = shift;

    $self->font('editor_tail' => SDLx::Text->new(
        font    => config->param('editor'=>'tail'=>'font'),
        size    => config->param('editor'=>'tail'=>'size'),
        color   => config->color('editor'=>'tail'=>'color'),
        mode    => 'utf8',
    ));
}

=head2

Draw FPS if it`s enabled in config file

=cut

sub draw_fps
{
    my ($self, $fps) = @_;

    return unless defined $fps;

    # Draw new FPS value
    $self->font('fps')->write_xy(
        $self->app,
        config->param('common'=>'fps'=>'left'),
        config->param('common'=>'fps'=>'top'),
        sprintf '%d fps', $fps
    );
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
    my ($self, $pkg) = @_;
    $pkg //= caller;

    my ($conf) = $pkg =~ m/^Game::TD::View::State::(.*?)$/;
    $conf = lc $conf;
    return $conf;
}

DESTROY
{
    my $self = shift;

    undef $self->{dest}{$_}     for keys %{ $self->{dest}   };
    undef $self->{font}{$_}     for keys %{ $self->{font}   };
    undef $self->{sprite}{$_}   for keys %{ $self->{sprite} };
    undef $self->{model};
    undef $self->{app};
}

1;