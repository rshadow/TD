use strict;
use warnings;
use utf8;

package Game::TD::Model;

=head1 Game::TD::Model

Model for TD game

=cut

=head1 FUNCTIONS

=cut

sub new
{
    my ($class, %opts) = @_;

    $opts{state} //= 'intro';

    my $self = bless \%opts, $class;

    return $self;
}

=head2 state $state

Set state of game: intro, memu, level, game

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

    return 1;
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
1;