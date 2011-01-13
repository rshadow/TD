use strict;
use warnings;
use utf8;

package Game::TD::View::Menu;
use base qw(Game::TD::View);

=head1 Game::TD::View::Menu

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

    my $self = $class->SUPER::new(%opts);

    return $self;
}

=head2 draw_intro

Draw intro

=cut

sub draw
{
    my ($self) = @_;

    $self->font_debug->print( $self->app, 200, 2, 'MENU' );
}

1;