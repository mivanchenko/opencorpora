package DumpFile;

use strict;
use warnings;

use XML::LibXML::Reader;
use XML::TreePuller;

$| = 1;  # I/O buffer off
binmode( STDOUT, ':encoding(utf8)' );

our %XPATHS = (
	'text' => '/annotation/text',
);


use Object::InsideOut;

my @file_name :Arg( 'Name' => 'file_name', 'Default' => 'test.xml' )
              :Field :Acc( file_name );

my @iterant_xpath :Default( $DumpFile::XPATHS{'text'} )
                  :Field :Acc( iterant_xpath );

my @mode :Default( 'subtree' )  # 'short' | 'subtree'
         :Field :Acc( mode );

my @puller :Field :Acc( puller );

sub init :Init {
	my ($self, $args) = @_;

	my $puller = XML::TreePuller->new( location => $self->file_name );

	$puller->iterate_at( $self->iterant_xpath, $self->mode );

	$self->puller( $puller );
}


sub texts {
	my ($self) = @_;

	if ( $self->iterant_xpath ne $XPATHS{'text'} ) {
		$self->puller->iterate_at( $XPATHS{'text'}, $self->mode );
	}

	return $self;
}

sub next {
	my ($self) = @_;
	return $self->puller->next;
}

1;

__END__

=head1 NAME

DumpFile - Iterator of OpenCorpora's L<XML dump file|http://opencorpora.org/?page=downloads>.

=head1 SYNOPSIS

 use DumpFile;

 my $dump_file = DumpFile->new( file_name => 'annot.opcorpora.xml' );

 while ( defined( my $text = $dump_file->texts->next ) ) {
 	print 'Id: ',   $text->attribute( 'id' ), "\n";
 	print 'Name: ', $text->name, "\n";
 	print 'Text: ', $text->text, "\n";
 	print "\n";
 }

=head1 METHODS

=head2 texts

Sets iterator to <text> elements. Returns C<$self> to allow chaining: C<< $self->texts->next >>.

=head2 next

Returns next L<XML::TreePuller::Element|http://search.cpan.org/~triddle/XML-TreePuller-0.1.2/lib/XML/TreePuller.pm#XML::TreePuller::Element>.

=head1 AUTHOR

L<OpenCorpora.org|http://opencorpora.org> team.

=head1 LICENSE

This program is free software, you can redistribute it under the same terms as Perl itself.
