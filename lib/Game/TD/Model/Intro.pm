use strict;
use warnings;
use utf8;

package Game::TD::Model::Intro;

use Game::TD::Config;

 # Show intro in 3 sec.
use constant SHOW_SECONDS => 5;

=head1 Game::TD::Model::Intro

Model for intro state

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

    my $self = bless \%opts, $class;

    # Current frame
    $self->{frame}{current} = 0;
    # Total frames for animation
    $self->{frame}{last}    = FRAMES_PER_SECOND * SHOW_SECONDS;
    # Delta frames for up alpha (alpha in 0 .. 255)
    $self->{frame}{delta}   = int( $self->last / 255 ) || 1;

    return $self;
}

sub update
{
    my $self = shift;

    $self->{frame}{current}++;

    return 0 if $self->{frame}{current} >= $self->{frame}{last};
    return $self->{frame}{last} - $self->{frame}{current};
}

sub current {return shift()->{frame}{current}}
sub last    {return shift()->{frame}{last}}
sub delta   {return shift()->{frame}{delta}}

1;