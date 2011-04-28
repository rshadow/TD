use strict;
use warnings;
use utf8;

package Game::TD::Model::Panel;
#use base qw(Exporter);
#our @EXPORT = qw();

use Game::TD::Config;

=head1 Game::TD::Model::Panel

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

    $opts{visible} //= 1;
    $opts{rect}     = SDL::Rect->new(
        config->param('common'=>'window'=>'width') -
            config->param('game'=>'panel'=>'width'),
        config->param('common'=>'window'=>'height') -
            config->param('game'=>'panel'=>'height'),
        config->param('game'=>'panel'=>'width'),
        config->param('game'=>'panel'=>'height')
    );

    my $self = bless \%opts, $class;



    return $self;
}

sub visible { return shift()->{visible} }
sub rect    { return shift()->{rect}    }

1;