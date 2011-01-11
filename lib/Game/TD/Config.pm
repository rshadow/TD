package Game::TD::Config;

use warnings;
use strict;
use utf8;

use base qw(Exporter);
our @EXPORT = qw(config);

use File::Basename;
use File::Spec;
use Config::Tiny;

=head1 NAME

Game::TD::Config - Load config

=head1 SYNOPSIS

  use Game::TD::Config;

=head1 DESCRIPTION

=cut

=head1 METHODS

=cut

=head2 cfg

Get cached config object

=cut

sub config
{
    our $config;

    # Cache config
    return $config if $config;
    $config = Game::TD::Config->new;
    return $config;
}

sub new
{
    my $class = shift;
    my %opts;

    # Make clean basedir
    $opts{dir}{base} = File::Spec->rel2abs( dirname(__FILE__) . '/../../..' );
    while( $opts{dir}{base} =~ s{(?:/[^\./]+/\.\.)}{}g ) {;}

    # Absolute resources dirs
    $opts{dir}{map}         = $opts{dir}{base} . '/data/map';
    $opts{dir}{img}         = $opts{dir}{base} . '/data/img';
    $opts{dir}{po}          = $opts{dir}{base} . '/po';
    $opts{dir}{config}      = $opts{dir}{base} . '/data';

    $opts{param} = Config::Tiny->read( $opts{dir}{config}.'/td.conf' );

    my $self = bless \%opts, $class;

    return $self;
}

sub dir
{
    my ($self, $name) = @_;
    die "Unknown directory name '$name'" unless exists $self->{dir}{$name};
    return $self->{dir}{$name};
}

sub param
{
    my ($self, $name) = @_;
    die "Unknown param name '$name'"
        unless exists $self->{param}{options}{$name};
    return $self->{param}{options}{$name};
}

1;