use strict;
use warnings;
use utf8;

package SDLx::Sprite::Splited;
use base qw(SDLx::Sprite::Animated);

=head1 NAME

SDLx::Sprite::Splited - Warpper for SDLx::Sprite::Animated to merge images
animation.

=head1 SYNOPSIS

    use SDLx::Sprite::Splited;

    # Create animation from array of images
    $spl = SDLx::Sprite::Splited->new(
        image   => [
            '/path_to/first_frame.png',
            '/path_to/second_frame.png',
            ...
        ],
    );

    # Create animation from hash of images sequences
    $spl = SDLx::Sprite::Splited->new(
        image   => {
            up  => [
                '/path_to_up/first_frame.png',
                '/path_to_up/second_frame.png',
                ...
            ],
            down  => [
                '/path_to_down/first_frame.png',
                '/path_to_down/second_frame.png',
                ...
            ]
        },
    );

    # Vertical mirror input surface
    $spl = SDLx::Sprite::Splited->new(
        image   => [
            '/path_to/first_frame.png',
            '/path_to/second_frame.png',
            ...
        ],
        transform => sub {
            # Input surface is SDLx::Surface
            my $surface = shift;

            # Vertical mirror input surface
            my $mirrored = SDL::GFX::Rotozoom::surface_xy(
                $surface->surface, 0, -1, 1, SMOOTHING_OFF );

            # You must return SDLx::Surface
            return SDLx::Surface->new(surface => $mirrored);
        },
    );

=head1 METHODS

=cut

=head2 new HASH

All options same as L<SDLx::Sprite::Animated>, except:

=over

=item image

Image can be list of images or hash of images sequences. See example.

=item transform

Transform subroutine, input and output objects must be SDLx::Surface

You can transform images in one sequence in another sequence. For example you
can set right movement sequence and transform 'vertical mirror' for left
movement sequence.

=back

=cut

sub new
{
    my ($class, %options) = @_;

    if('ARRAY' eq ref $options{image})
    {
        # Option 'image' will replace by 'surface'
        my $images      = delete $options{image};
        my $transform   = delete $options{transform};

        my ($full, $width, $height) = _load_splited($images, $transform);

        # Set big surface
        $options{surface} = $full;
        # Correct width and height if not defined
        $options{width}  = $width           unless defined $options{width};
        $options{height} = $height          unless defined $options{height};
    }
    elsif('HASH' eq ref $options{image})
    {
        my $images    = delete $options{image};
        my $transform = delete $options{transform};

        my ($full, $sequences, $width, $height) =
            _load_sequences($images, $transform);

        # Set big surface and sequences
        $options{surface}   = $full;
        $options{sequences} = $sequences    unless defined $options{sequences};
        # Correct width and height if not defined
        $options{width}     = $width        unless defined $options{width};
        $options{height}    = $height       unless defined $options{height};
        #
        $options{step_x}    = 1             unless defined $options{step_x};
        $options{step_y}    = 1             unless defined $options{step_y};
    }

    return $class->SUPER::new(%options);
}

=head2 _load_splited $images

Load array of $images and make one big surface. Return list of surface, one
image width and one image height

=cut

sub _load_splited
{
    my ($images, $transform) = @_;

    my @sprites = ();
    my ($width, $height) = (0, 0);

    my ($frame_w, $frame_h) = (0, 0);

    # Load all images and count total width
    for my $image (@$images)
    {
        # Load frame from image file
        my $frame = SDLx::Surface->load( $image );

        # Run transform if defined
        $frame = $transform->($frame) if defined $transform;

        # Set alpha for correct blit
        SDL::Video::set_alpha($frame->surface, 0, 0);

        # Count total size and save in list of frames
        $width += $frame->w;
        $height = $frame->h if $height < $frame->h;
        push @sprites, $frame;

        # Store first image size as default
        $frame_w = $frame->w unless $frame_w;
        $frame_h = $frame->h unless $frame_h;
    }

    # Create one big surface
    my $full = SDLx::Surface->new( width => $width, height => $height );

    # Blit images on one big surface
    my $x = 0;
    for (@sprites) {
        $_->blit($full, undef, SDL::Rect->new($x, 0, 0, 0));
        $x += $_->w;
    }

    return ($full, $frame_w, $frame_h);
}

sub _load_sequences
{
    my ($images, $transform) = @_;
    my %sequences;
    my ($frame_w, $frame_h) = (0, 0);

    # Load parts sequence
    my %parts = ();
    for my $name (keys %$images)
    {
        # Load part from image files
        my ($part, $width, $height) =
            _load_splited($images->{$name}, $transform->{$name});

        # Set alpha for correct blit
        SDL::Video::set_alpha($part, 0, 0);

        # Save part
        $parts{$name} = {
            surface => $part,
            width   => $width,
            height  => $height
        };

        # Store first image size as default
        $frame_w = $width  unless $frame_w;
        $frame_h = $height unless $frame_h;
    }

    my $width  = 0;
    my $height = 0;
    for my $name (keys %parts)
    {
        $width   = $parts{$name}{surface}->w if
            $width < $parts{$name}{surface}->w;
        $height += $parts{$name}{surface}->h;
    }

    # Create one big surface
    my $full = SDLx::Surface->new( width => $width, height => $height );

    # Blit images on one big surface
    my $y = 0;
    for my $name (keys %parts)
    {
        $parts{$name}{surface}->blit($full, undef, SDL::Rect->new(0, $y, 0, 0));

        # Set sequences
        for(my $index = 0; $index < @{$images->{$name}}; $index++)
        {
            my $x = $index * $parts{$name}{width};
            push @{$sequences{$name}}, [$x, $y];
        }

        $y += $parts{$name}{surface}->h;
    }

    return ($full, \%sequences, $frame_w, $frame_h);
}

1;