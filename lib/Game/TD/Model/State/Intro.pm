use strict;
use warnings;
use utf8;

package Game::TD::Model::State::Intro;

use Game::TD::Config;

=head1 Game::TD::Model::State::Intro

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

    # Start alpha value
    $self->{alpha} = 0;
    # Count total frames for show
    $self->{left}  = config->param('common'=>'fps'=>'value') *
                     config->param('intro'=>'duration');

    return $self;
}

sub update
{
    my $self = shift;

    # Update alpha if need
    unless( $self->{alpha} == 255 )
    {
        $self->{alpha} += config->param('intro'=>'logo'=>'astep');
        $self->{alpha} = 255 if $self->{alpha} > 255;
    }

    $self->{left}-- if $self->{left} >= 0;
    return $self->left;
}

sub alpha   {return shift()->{alpha}}
sub left    {return shift()->{left}}

1;