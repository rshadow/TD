use strict;
use warnings;
use utf8;

package Game::TD::Config;

use base qw(Exporter);
our @EXPORT = qw(config Dumper notify debug);

use Carp;
use File::Basename;
use File::Spec;
use Data::Dumper;

use Game::TD::Notify;

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

sub base
{
    our $base;
    return $base if $base;
    $base = File::Spec->rel2abs( dirname(__FILE__) . '/../../..' );
    while( $base =~ s{(?:/[^\./]+/\.\.)}{}g ) {;}
    return $base;
}

sub new
{
    my $class = shift;
    my %opts;

    # Absolute resources dirs
#    $opts{dir}{img}         = $opts{dir}{base} . '/data/img';
    $opts{dir}{po}          = base . '/po';
    $opts{dir}{config}      = base . '/data/conf';
    $opts{dir}{level}       = base . '/data/level';
#    $opts{dir}{layout}      = $opts{dir}{base} . '/data/layout';

#    $opts{dir}{intro}       = $opts{dir}{img} . '/intro';
#    $opts{dir}{game}        = $opts{dir}{img} . '/game';
#    $opts{dir}{level}       = $opts{dir}{img} . '/level';
#    $opts{dir}{menu}        = $opts{dir}{img} . '/menu';
#    $opts{dir}{score}       = $opts{dir}{img} . '/score';


    my $self = bless \%opts, $class;

    # Get config files
    # Common must be first becouse it`s values used next config files
    my @conf = glob sprintf '%s/*.conf', $self->dir('config');
    for (my $index = 0; $index < @conf; $index++ )
    {
        if( $conf[$index] =~ m{/common\.conf$} )
        {
            # Skip if already first
            last if $index == 0;
            # Move "common" in first position
            my $common = splice @conf, $index, 1;
            unshift @conf, $common;
            last;
        }
    }

    # Add user config if exists and readable
    my $uconf = glob '~/.td/user.conf';
    push( @conf, $uconf ) if -f $uconf && -r _ && -s _;

    # Load params from config files
    for my $path (@conf)
    {
        my ($name) = $path =~ m{^.*/(.*?)\.conf$};
        local $/;
        open my $cnf, '<', $path                       or die $!;
        my %params = eval <$cnf>;
        die sprintf 'Error in %s: %s', $path, $@ if $@;
        # Concat config (for user config)
        $self->{param}{$name} = {( %{$self->{param}{$name} || {}}, %params )};
        close $cnf                                     or die $!;
    }

    return $self;
}

sub dir
{
    my ($self, $name) = @_;
    croak "Unknown directory name '$name'" unless exists $self->{dir}{$name};
    return $self->{dir}{$name};
}

=head2 param $name, @path

Get param from part $name by @path

=cut

sub param
{
    my ($self, @path) = @_;
    my $path = '$self->{param}';
    $path .= '{\''.$_.'\'}' for @path;
    my $result = eval $path;
    return $result;
}

1;