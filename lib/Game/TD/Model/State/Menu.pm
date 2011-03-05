use strict;
use warnings;
use utf8;

package Game::TD::Model::State::Menu;
use base qw(Game::TD::Model);

=head1 Game::TD::Model::State::Menu

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

#    $opts{current} //= 0;

    my $self = $class->SUPER::new(%opts);

    $self->{items} = [
        {name => 'play',    title => 'Play'},
        {name => 'score',   title => 'Score'},
        {name => 'exit',    title => 'Exit'},];

    # Get current version
    {{
        eval {require Game::TD};
        die $@ if $@;
        $self->{version} = $Game::TD::VERSION;
    }}

    return $self;
}

#sub up
#{
#    my $self = shift;
#    $self->{current}-- if $self->{current} > 0;
#    return 1;
#}
#
#sub down
#{
#    my $self = shift;
#    $self->{current}++ if $self->{current} < $#{$self->items};
#    return 1;
#}

#sub current {return shift()->{current}}
sub version {return shift()->{version}}

sub items
{
    my $self = shift;
    return (wantarray) ?@{$self->{items}} :$self->{items};
}

1;