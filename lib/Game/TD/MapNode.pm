package Game::TD::MapNode;

use warnings;
use strict;
use utf8;

=head1 NAME

Game::TD::MapNode - One square node of map

=head1 SYNOPSIS

  use Game::TD::MapNode;

=head1 DESCRIPTION

=cut

=head1 METHODS

=cut

sub new
{
    my ($class, %opts) = @_;

    my @types = qw(glade road cross tree stone start finish water);

    $opts{type}     //= 'glade';
    $opts{tower}    //= undef;
    $opts{index}    //= 0;

    die sprintf 'Unknown map node type "%s"', $opts{type}
        unless $opts{type} ~~ @types;

    my $self = bless \%opts, $class;

    return $self;
}

1;