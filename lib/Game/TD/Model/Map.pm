package Game::TD::Model::Map;

use warnings;
use strict;
use utf8;

use Game::TD::Config;
use Game::TD::Model::MapNode;

=head1 NAME

Game::TD::Map - Load and store current level map

=head1 SYNOPSIS

  use Game::TD::Map;

=head1 DESCRIPTION

=cut

=head1 METHODS

=cut

use constant FILE_EXTENSION => 'map';

sub new
{
    my ($class, %opts) = @_;

    die 'Required name of the map' unless defined $opts{name};

    $opts{file} = sprintf '%s/%s.%s',
        config->dir('map'), $opts{name}, FILE_EXTENSION;

    my $self = bless \%opts, $class;

    $self->_load or die 'Can`t load map file';

    return $self;
}

=head2

Load map from file

=cut

sub _load
{
    my ($self) = @_;

    # Load string map from file
    my $raw = '';
    open my $file, '<', $self->{file}
        or die sprintf 'Map file "%s" not exists', $self->{file};
    {
        local $/ = '';
        $raw = <$file>;
    }
    close $file;

    # Split and check map
    my @lines = grep m/\S+/, split m/\s/, $raw;
    my $width = length($lines[0]) / 2;

    for my $y ( 0 .. $#lines )
    {
        die "Bad map symbol detected in line $y"
            if $lines[$y] =~ m/[^A-Z0-9]/;
        die "Bad width in map line $y", $lines[$y]
            unless $width == (length($lines[$y]) / 2);
    }

    # Convert into array
    my ($y, @map) = (0, ());
    for my $line (@lines)
    {
        my @line = $line =~ m/(.{2})/g;
        for my $x (0 .. $#line)
        {
            $map[$x][$y] = $line[$x];
        }
        $y += 1;
    }

    # Convert into map nodes
    for my $line (@map)
    {
        for my $node (@$line)
        {
            my ($letter, $index) = split m//, $node;
            my $type =
                ($letter eq 'G')    ?'glade'    :
                ($letter eq 'R')    ?'road'     :
                ($letter eq 'C')    ?'cross'    :
                ($letter eq 'T')    ?'tree'     :
                ($letter eq 'N')    ?'stone'    :
                ($letter eq 'S')    ?'start'    :
                ($letter eq 'F')    ?'finish'   :
                ($letter eq 'W')    ?'water'
                                    : die "Unknown map node type: $letter";

            $node = Game::TD::Model::MapNode->new(
                type => $type, index => $index);
        }
    }

    # Store map in object
    $self->{map}    = \@map;
    $self->{width}  = $width;
    $self->{height} = scalar @lines;

    return 1;
}

1;