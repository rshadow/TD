use strict;
use warnings;
use utf8;

package Game::TD::Controller;

# Use raw SDL constants for events
use Exporter;
use SDL::Constants;

use Game::TD::Model::Intro;
use Game::TD::Model::Menu;

use Game::TD::View::Intro;
use Game::TD::View::Menu;

=head1 Game::TD::Model

Model for TD game

=cut

=head1 FUNCTIONS

=cut

sub new
{
    my ($class, %opts) = @_;

    die 'Missing required param "app"' unless defined $opts{app};
    $opts{state} //= 'intro';

    my $self = bless \%opts, $class;

    $self->model(intro => Game::TD::Model::Intro->new);
    $self->model(menu  => Game::TD::Model::Menu->new);

    $self->view(intro  => Game::TD::View::Intro->new(
        app => $self->app, model => $self->model('intro')
    ));
    $self->view(menu   => Game::TD::View::Menu->new(
        app => $self->app, model => $self->model('menu')
    ));

    return $self;
}

=head2 state $state

Set state of game: intro, memu, level, game, score

=cut

sub state
{
    my ($self, $state) = @_;
    $self->{state} = $state if defined $state;
    return $self->{state};
}

=head2 update

Handler for update model event

=cut

sub update
{
    my ($self) = @_;

    if($self->state eq 'intro')
    {
        unless( $self->model('intro')->update )
        {
            # Goto Menu
            $self->state('menu');
            # Free memory
            $self->free('intro');
        }
    }
    elsif($self->state eq 'menu')
    {
    }
    elsif($self->state eq 'level')
    {
    }
    elsif($self->state eq 'game')
    {
    }
    elsif($self->state eq 'score')
    {
    }
    else
    {
        die 'Unknown game state';
    }

    return 1;
}

=head2 draw

Handler for update view event

=cut

sub draw
{
    my $self = shift;

    if($self->state eq 'intro')
    {
        $self->view('intro')->draw;
    }
    elsif($self->state eq 'menu')
    {
        $self->view('menu')->draw;
    }
    elsif($self->state eq 'level')
    {
    }
    elsif($self->state eq 'game')
    {
    }
    elsif($self->state eq 'score')
    {
    }
    else
    {
        die 'Unknown game state';
    }

    return 1;
}

=head2 draw_fps $fps

Handler for update $fps count event

=cut

sub draw_fps
{
    my ($self, $fps) = @_;

    if($self->state eq 'intro')
    {
        $self->view('intro')->draw_fps($fps);
    }
    elsif($self->state eq 'menu')
    {
        $self->view('menu')->draw_fps($fps);
    }
    elsif($self->state eq 'level')
    {
    }
    elsif($self->state eq 'game')
    {
    }
    elsif($self->state eq 'score')
    {
    }
    else
    {
        die 'Unknown game state';
    }
}

=head2 key_up $key

Handler for $key up event

=cut

sub key_up
{
    my ($self, $key) = @_;

    if($self->state eq 'intro')
    {
        # Goto Menu
        $self->state('menu');
        # Free memory
        $self->free('intro');
    }
    elsif($self->state eq 'menu')
    {
    }
    elsif($self->state eq 'level')
    {
    }
    elsif($self->state eq 'game')
    {
    }
    else
    {
        die 'Unknown game state';
    }
}

=head2 key_down $key

Handler for $key down event

=cut

sub key_down
{
    my ($self, $key) = @_;

    if($self->state eq 'intro')
    {
        # Goto Menu
        $self->state('menu');
        # Free memory
        $self->free('intro');
    }
    elsif($self->state eq 'menu')
    {
        ($key == SDLK_UP)   ? $self->model('menu')->up       :
        ($key == SDLK_DOWN) ? $self->model('menu')->down     : ();
    }
    elsif($self->state eq 'level')
    {
    }
    elsif($self->state eq 'game')
    {
    }
    else
    {
        die 'Unknown game state';
    }
}

=head2 mouse_motion $x, $y

Handler for mouse move. Coordinates in set in $x, $y.

=cut

sub mouse_motion
{
    my ($self, $x, $y) = @_;

    if($self->state eq 'intro')
    {
    }
    elsif($self->state eq 'menu')
    {
    }
    elsif($self->state eq 'level')
    {
    }
    elsif($self->state eq 'game')
    {
    }
    else
    {
        die 'Unknown game state';
    }
}

=head2 mouse_button_down $button

Handler for mouse $button down event

=cut

sub mouse_button_down
{
    my ($self, $button) = @_;

    if($self->state eq 'intro')
    {
        # Goto Menu
        $self->state('menu');
        # Free memory
        $self->free('intro');
    }
    elsif($self->state eq 'menu')
    {
    }
    elsif($self->state eq 'level')
    {
    }
    elsif($self->state eq 'game')
    {
    }
    else
    {
        die 'Unknown game state';
    }
}

=head2 mouse_button_up $button

Handler for mouse $button up event

=cut

sub mouse_button_up
{
    my ($self, $button) = @_;

    if($self->state eq 'intro')
    {
        # Goto Menu
        $self->state('menu');
        # Free memory
        $self->free('intro');
    }
    elsif($self->state eq 'menu')
    {
    }
    elsif($self->state eq 'level')
    {
    }
    elsif($self->state eq 'game')
    {
    }
    else
    {
        die 'Unknown game state';
    }
}

=head2 app

Get SDL App object

=cut

sub app
{
    return shift()->{app}
}

=head2 view $name, $value

Set view object $name if set $value or return if $value not set.

=cut

sub view
{
    my ($self, $name, $value) = @_;

    die 'Name required'             unless defined $name;
    $self->{view}{$name} = $value   if defined $value;
    return $self->{view}{$name};
}

=head2 model $name, $value

Set model object $name if set $value or return if $value not set.

=cut

sub model
{
    my ($self, $name, $value) = @_;

    die 'Name required'             unless defined $name;
    $self->{model}{$name} = $value  if defined $value;
    return $self->{model}{$name};
}

=head2 free $name

Free unused objects by state name

=cut

sub free
{
    my ($self, $name) = @_;
    delete $self->{view}{$name};
    delete $self->{model}{$name};
}
1;