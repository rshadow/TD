use strict;
use warnings;
use utf8;

package Game::TD::Model::Tail;
#use base qw(Exporter);
#our @EXPORT = qw();

=head1 Game::TD::Model::Tail

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

    my $self = bless \%opts, $class;

    return $self;
}

sub x       { return shift()->{x}    }
sub y       { return shift()->{y}    }
sub type    { return shift()->{type} }
sub mod     { return shift()->{mod}  }

sub has_item
{
    my ($self) = @_;
    return exists $self->{item} ? 1 : 0;
}

sub item_type
{
    my ($self) = @_;
    return undef unless exists $self->{item};
    return undef unless exists $self->{item}{type};

    return $self->{item}{type};
}

sub item_mod
{
    my ($self) = @_;
    return undef unless exists $self->{item};
    return undef unless exists $self->{item}{mod};

    return $self->{item}{mod};
}

sub has_path
{
    my ($self) = @_;
    return exists $self->{path} ? 1 : 0;
}

sub has_path_name
{
    my ($self, $name) = @_;

    return 0 unless exists $self->{path};
    return 1 if exists $self->{path} and ! defined $name;

    my @path = ('ARRAY' eq ref $self->{path})
        ? @{ $self->{path} }
        :  ( $self->{path} );

    return (grep {$_->{name} eq $name } @path) ? 1 : 0;
}

sub has_path_type
{
    my ($self, $type) = @_;

    return 0 unless exists $self->{path};

    my @path = ('ARRAY' eq ref $self->{path})
        ? @{ $self->{path} }
        :  ( $self->{path} );

    return (grep {defined $_->{type} and $_->{type} eq $type } @path) ? 1 : 0;
}

1;