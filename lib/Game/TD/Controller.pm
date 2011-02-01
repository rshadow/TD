use strict;
use warnings;
use utf8;

package Game::TD::Controller;

use SDL;

use Game::TD::Model::Player;

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
    if($type eq SDL_QUIT or SDL::GetKeyState(SDLK_ESCAPE))
    {
        $result{quit} = 1;
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

=head2 DESTROY

Free model and view resources

=cut

DESTROY
{
    my $self = shift;
    delete $self->{view};
    delete $self->{model};
    delete $self->{app};
}

1;