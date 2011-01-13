use strict;
use warnings;
use utf8;

package Game::TD::Controller;

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

    $self->{model}{intro}  = Game::TD::Model::Intro->new;
    $self->{model}{menu}   = Game::TD::Model::Menu->new;

    $self->{view}{intro}   = Game::TD::View::Intro->new(
        app => $self->app, model => $self->model_intro );
    $self->{view}{menu}    = Game::TD::View::Menu->new(
        app => $self->app, model => $self->model_menu );

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

sub update
{
    my ($self) = @_;

    if($self->state eq 'intro')
    {
        unless( $self->model_intro->update )
        {
            # Goto Menu
            $self->state('menu');
            # Free memory
            delete $self->{model}{intro};
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

=head2

Draw game state

=cut

sub draw
{
    my $self = shift;

    if($self->state eq 'intro')
    {
        $self->view_intro->draw;
    }
    elsif($self->state eq 'menu')
    {
        $self->view_menu->draw;
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

sub draw_fps
{
    my ($self, $fps) = @_;

    if($self->state eq 'intro')
    {
        $self->view_intro->draw_fps($fps);
    }
    elsif($self->state eq 'menu')
    {
        $self->view_menu->draw_fps($fps);
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

sub key_up
{
    my $self = shift;
    return unless $self->state eq 'menu';
    $self->menu->up;
}

sub key_down
{
    my $self = shift;
    return unless $self->state eq 'menu';
    $self->menu->down;
}

sub key_any
{
    my $self = shift;

    if($self->state eq 'intro')
    {
        $self->state('menu');
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


sub app          {return shift()->{app}}
sub view_intro   {return shift()->{view}{intro}}
sub view_menu    {return shift()->{view}{menu}}
sub model_intro  {return shift()->{model}{intro}}
sub model_menu   {return shift()->{model}{menu}}
1;