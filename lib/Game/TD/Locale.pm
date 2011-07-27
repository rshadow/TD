use strict;
use warnings;
use utf8;

=head1 Game::TD::Locale

Translate strings use *.po files

=cut

package Game::TD::Locale;
use base qw(Exporter);

use Locale::Language;
use Locale::PO;
use Encode qw(is_utf8 decode);
use Carp;

our @EXPORT_OK = qw(po gettext);

our $po;

=head2 po

Translate string

=cut

sub po
{
    my ($class, %opts) = @_;
    # Chache po object
    return $po if $po;
    return $po = $class->new(%opts);
}

=head2 new

=cut

sub new
{
    my ($class, %opts) = @_;

    # Set default
    my ($current) = $ENV{LANG} =~ m/^([a-z]+)/;
    $opts{locale} //= lc($current) || 'en';

    # Set default dir
    $opts{dir}    //= 'po';

    # Get available translations
    my @langs = map {$_->{code}} available($opts{dir});
    warn 'No translation files' unless @langs;

    # Check for pod file and drop to default if not exists
    unless ($opts{locale} ~~ @langs) {
        warn sprintf('Locale %s not found', uc $opts{locale});
        $opts{locale} = 'en';
    }

    my $self = bless \%opts, $class;

    # Reload locale in first time
    $self->locale( $self->locale );

    return $self;
}

=head2 locale

Set or get current locale

=cut

sub locale
{
    my ($self, $locale) = @_;
    # Return current if not specified
    return $self->{locale} unless defined $locale;

    # Set and reload if new locale set
    $self->{locale} = $locale || 'en';
    $self->{data}     = Locale::PO->load_file_ashash(
        sprintf '%s/%s.po', $self->{dir}, $self->{locale});

    return $self->{locale};
}

=head2 gettext

Get translated string by untranslated string. Can be used as OOP and functional
style.

=cut

sub gettext
{
    my ($param1, $param2) = @_;

    my ($self, $string);

    # If OOP
    if('Game::TD::Locale' eq ref $param1)
    {
        $self = $param1;
        $string = $param2;
    }
    # If functional
    else
    {
        $self = po;
        $string = $param1;
    }

    confess 'String not defined' unless defined $string;
    my $id = '"'.$string.'"';

    # Return translated string if exists or as is
    $string = $self->{data}{$id}->dequote( $self->{data}{$id}->msgstr ) ||
        $self->{data}{$id}->dequote( $self->{data}{$id}->msgid )  ||
        $string
            if exists $self->{data}{$id};
    $string = decode utf8 => $string unless is_utf8 $string;
    return $string;
}

=head2 available

Get available translations

=cut

sub available
{
    my ($dir) = @_;

    # Get available translations
    return
        map { { code => $_, name => code2language $_} }
        map { m|/(\w*?).po$| } glob sprintf '%s/*.po', $dir;
}

1;

=head1 AUTHORS

Copyright (C) 2008 Dmitry E. Oboukhov <unera@debian.org>,

Copyright (C) 2008 Roman V. Nikolaev <rshadow@rambler.ru>

=head1 LICENSE

This program is free software: you can redistribute  it  and/or  modify  it
under the terms of the GNU General Public License as published by the  Free
Software Foundation, either version 3 of the License, or (at  your  option)
any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even  the  implied  warranty  of  MERCHANTABILITY  or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public  License  for
more details.

You should have received a copy of the GNU  General  Public  License  along
with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut
