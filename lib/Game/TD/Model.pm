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

=head2 result $name, $value

Accumulate result values. When you get this hash it`s destroy.

=cut

sub result
{
    my ($self, $name, $value) = @_;

    if(defined $name and defined $value)
    {
        $self->{result}{$name} = $value;
        return $self->{result}{$name};
    }
    elsif(defined $name)
    {
        return $self->{result}{$name};
    }

    return delete $self->{result};
}

sub DESTROY
{
    my $self = shift;

    undef $self->{timer}{$_} for keys %{ $self->{timer} };
}

sub dt        { return shift()->{dt}; }

1;
