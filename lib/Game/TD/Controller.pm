use strict;
use warnings;
use utf8;

package Game::TD::Controller;

use Carp;
use SDL;
use SDL::Event;
use Game::TD::Config;

use SDLx::Text;
use SDLx::Widget::Button;


=head1 Game::TD::Model

Model for TD game

=cut

=head1 FUNCTIONS

=cut

sub new
{
    my ($class, %opts) = @_;

    die 'Missing required param "app"' unless defined $opts{app};

    my $self = bless \%opts, $class;

    return $self;
}

=head2 update

Handler for update model event

=cut

sub update
{
    my ($self) = @_;

    $self->model->update;

    return {};
}

=head2 draw

Handler for update view event

=cut

sub draw
{
    my $self = shift;

    $self->view->draw;

    return 1;
}

=head2 draw_fps $fps

Handler for update $fps count event

=cut

sub draw_fps
{
    my ($self, $fps) = @_;

    $self->view->draw_fps($fps);
}

=head2 event $event

Handler for user $event

=cut

sub event
{
    my ($self, $event) = @_;

    my %result;
    my $type = $event->type;

    # Quit if Esc
    if($type eq SDL_QUIT)
    {
        $result{quit} = 1;
    }
    elsif($type == SDL_KEYDOWN)
    {
        my $key = $event->key_sym;

        if($key == SDLK_ESCAPE)
        {
            $result{quit} = 1;
        }
    }

    return \%result;
}

=head2 app

Get SDL App object

=cut

sub app
{
    my $self = shift;
    return $self->{app};
}

=head2 view $value

Set view object if set $value or return if $value not set.

=cut

sub view
{
    my ($self, $value) = @_;

    $self->{view} = $value   if defined $value;
    return $self->{view};
}

=head2 model $value

Set model object if set $value or return if $value not set.

=cut

sub model
{
    my ($self, $value) = @_;

    $self->{model} = $value  if defined $value;
    return $self->{model};
}

=head2 button $name, $value

Common storage for buttons on screen. Get $name for button and typically
SDLx::Widget::Button object in $value.

=cut

sub button
{
    my ($self, $name, $conf, $surface, %opts) = @_;

    croak 'Name required'             unless defined $name;

    if(defined $conf and defined $surface)
    {
        $opts{image}    = config->param($conf=>'buttons'=>$name=>'image')
            if config->param($conf=>'buttons'=>$name=>'image');
        $opts{images}   = config->param($conf=>'buttons'=>$name=>'images')
            if config->param($conf=>'buttons'=>$name=>'images');
        $opts{step_x}   = 1;
        $opts{step_y}   = 1;
        $opts{parent}   = $surface;
        $opts{rect}     = SDL::Rect->new(
                @{config->param($conf=>'buttons'=>$name=>'rect')} );
        $opts{sequences} = config->param($conf=>'buttons'=>$name=>'sequences');

        my $text  = config->param($conf=>'buttons'=>$name=>'text') || '';
        if(length $text )
        {
            $opts{text}  = SDLx::Text->new(
                font    => config->param($conf=>'buttons'=>$name=>'font'),
                size    => config->param($conf=>'buttons'=>$name=>'size'),
                color   => config->param($conf=>'buttons'=>$name=>'color'),
                mode    => 'utf8',
                h_align => 'left',
                text    => $text,
            );
        }

        $self->{button}{$name} = SDLx::Widget::Button->new(%opts);
    }

    return $self->{button}{$name};
}

=head2 conf

Return config part name by controller package name

=cut

sub conf
{
    my $self = shift;
    my $pkg = caller;
    my ($conf) = $pkg =~ m/^Game::TD::Controller::State::(.*?)$/;
    $conf = lc $conf;
    return $conf;
}

=head2 DESTROY

Free model and view resources

=cut

DESTROY
{
    my $self = shift;

    undef $self->{button}{$_} for keys %{ $self->{button} };
    undef $self->{view};
    undef $self->{model};
    undef $self->{app};
}

1;