use warnings;
use strict;

package RT::Extension::MagicContentType;

our $VERSION = "0.01";
use RT::Attachment;

package RT::Attachment;
use File::MimeInfo::Magic;
use IO::Scalar;

eval { require File::LibMagic };
my $flm;

unless ( $@ ) {
    $flm = File::LibMagic->new();
}

my $new = sub {
    my $self         = shift;
    my $content_type = shift;

    # only customize *real* attachments 
    return $content_type unless $self->Filename;

    my $content =
      $self->_DecodeLOB( $content_type, $self->ContentEncoding,
        $self->_Value( 'Content', decode_utf8 => 0 ),
      );
    return $content_type unless $content;

    my $magic_type;

    if ($flm) {
        $magic_type = $flm->checktype_contents($content);
        return $content_type unless $magic_type;
        $magic_type =~ s/;.*//;    # we don't need charset info
    }
    else {
        require File::MimeInfo::Magic;
        require IO::Scalar;
        $magic_type =
          File::MimeInfo::Magic::mimetype( IO::Scalar->new( \$content ) );
    }

    return $magic_type || $content_type;
};

my $old = __PACKAGE__->can('ContentType');

if ($old) {
    no warnings 'redefine';
    *ContentType = sub {
        my $self = shift;
        my $content_type = $old->($self, @_ );
        return $content_type unless defined $content_type;
        return $new->($self, $content_type);
    };
}
else {
    *ContentType = sub {
        my $self = shift;
        my $content_type = $self->_Value('ContentType');
        return $content_type unless defined $content_type;
        return $new->($self, $content_type);
    };
}

1;

__END__

=head1 NAME

RT::Extension::MagicContentType - Attachments' Magic ContentType

=head1 VERSION

Version 0.01

=head1 INSTALLATION

To install this module, run the following commands:

    perl Makefile.PL
    make
    make install

add RT::Extension::MagicContentType to @Plugins in RT's etc/RT_SiteConfig.pm:

    Set( @Plugins, qw(... RT::Extension::MagicContentType) );

=head1 AUTHOR

sunnavy, <sunnavy at bestpractical.com>


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Best Practical Solutions, LLC.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

