use strict;
use warnings;
use utf8;

package Game::TD::Model;

use SDLx::Controller::Timer;

=head1 Game::TD::Model

Описание_модуля

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

    $opts{dt} //= 1;

    my $self = bless \%opts, $class;

    return $self;
}

sub update
{
    return;
}

sub timer
{
    my ($self, $name, $flag) = @_;
    die 'Missing required parameter "name"' unless defined $name;
    $self->{timer}{$name} = SDLx::Controller::Timer->new() if defined $flag;
    return $self->{timer}{$name};
}

sub timers
{
    my ($self) = @_;
    return wantarray ?%{$self->{timer}} : $self->{timer};
}

sub DESTROY
{
    my $self = shift;

    undef $self->{timer}{$_} for keys %{ $self->{timer} };
}

sub dt        { return shift()->{dt}; }

1;
