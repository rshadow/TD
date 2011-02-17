use strict;
use warnings;
use utf8;

package Game::TD::Model::Timer;

use SDL;

=head1 Game::Timer

Time managment

=cut

sub new
{
    my ($class, %opts) = @_;

    $opts{start_ticks}  = 0;
    $opts{paused_ticks} = 0;
    $opts{started}      = 0;
    $opts{paused}       = 0;

    my $self = bless \%opts, $class;

    return $self;
}

sub start
{
    my $self = shift;

    # Start the timer
    $self->{started} = 1;
    # Unpause the timer
    $self->{paused} = 0;
    # Get the current clock time
    $self->{start_ticks} = SDL::GetTicks();
}

sub stop
{
    my $self = shift;

    # Stop the timer
    $self->{started} = 0;
    # Unpause the timer
    $self->{paused}  = 0;
}

sub get_ticks
{
    my $self = shift;

    # If the timer is running
    if( $self->{started} == 1 )
    {
        # If the timer is paused
        if( $self->{paused} == 1 )
        {
            # Return the number of ticks when the timer was paused
            return $self->{paused_ticks};
        }
        else
        {
            # Return the current time minus the start time
            return SDL::GetTicks() - $self->{start_ticks};
        }
    }

    # If the timer isn't running
    return 0;
}

sub pause
{
    my $self = shift;

    if( $self->{started} == 1 && $self->{paused} == 0 )
    {
        $self->{paused} = 1;
        $self->{paused_ticks} = SDL::GetTicks() - $self->{start_ticks};
    }
}

sub unpause
{
    my $self = shift;

    if( $self->{paused} == 1 )
    {
        $self->{paused} = 0;
        $self->{start_ticks} = SDL::GetTicks() - $self->{paused_ticks};
        $self->{paused_ticks} = 0;
    }
}

sub is_started { return shift()->{started} }
sub is_paused  { return shift()->{paused}  }

1;