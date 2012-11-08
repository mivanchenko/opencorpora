package DumpFile;

use strict;
use warnings;

use XML::LibXML::Reader;
use XML::TreePuller;

$| = 1;  # I/O buffer off
binmode( STDOUT, ':encoding(utf8)' );

our %XPATHS = (
	'text'      => '/annotation/text',
	'paragraph' => '/annotation/text/paragraphs/paragraph',
	'sentence'  => '/annotation/text/paragraphs/paragraph/sentence',
);


use Object::InsideOut;

my @file_name :Arg( 'Name' => 'file_name', 'Default' => 'test.xml' )
              :Field :Acc( file_name );

my @iterant_xpath :Default( $DumpFile::XPATHS{'text'} )
                  :Field :Acc( iterant_xpath );

my @mode :Default( 'subtree' )  # 'short' | 'subtree'
         :Field :Acc( mode );

my @iterator :Field :Acc( iterator );

sub init :Init {
	my ($self, $args) = @_;

	my $iterator = XML::TreePuller->new( location => $self->file_name );
	$iterator->iterate_at( $self->iterant_xpath, $self->mode );
	$self->iterator( $iterator );
}


sub texts {
	my ($self) = @_;
	$self->_set_iterator( 'text' );
	return $self;
}

sub paragraphs {
	my ($self) = @_;
	$self->_set_iterator( 'paragraph' );
	return $self;
}

sub sentences {
	my ($self) = @_;
	$self->_set_iterator( 'sentence' );
	return $self;
}

sub _set_iterator {
	my ($self, $iterant) = @_;

	if ( $self->iterant_xpath ne $XPATHS{ $iterant } ) {
		# create iterator from current iterant
		my $iterator = XML::TreePuller->new( location => $self->file_name );
		$iterator->iterate_at( $XPATHS{ $iterant }, $self->mode );

		# set iterator
		$self->iterator( $iterator );

		# save current iterant
		$self->iterant_xpath( $XPATHS{ $iterant } );

		return 1;
	}

	return;
}

sub next {
	my ($self) = @_;
	my $next = $self->iterator->next;

	# add a method 'id' to 'next element'
	*XML::TreePuller::Element::id = sub {
		return $next->attribute( 'id' );
	};

	return $next;
}

1;

__END__

=head1 NAME

DumpFile - Iterator for L<OpenCorpora|http://opencorpora.org>'s L<XML dump file|http://opencorpora.org/?page=downloads>.

=head1 SYNOPSIS

 use DumpFile;

 my $dump_file = DumpFile->new( file_name => 'annot.opcorpora.xml' );

 while ( defined( my $text = $dump_file->texts->next ) ) {
 	print 'Id: ',   $text->attribute( 'id' ), "\n";
 	print 'Id: ',   $text->id, "\n";
 	print 'Name: ', $text->name, "\n";
 	print 'Text: ', $text->text, "\n", "\n";
 }

 while ( defined( my $paragraph = $dump_file->paragraphs->next ) ) {
 	print 'Id: ',   $paragraph->attribute( 'id' ), "\n";
 	print 'Id: ',   $paragraph->id, "\n";
 	print 'Name: ', $paragraph->name, "\n";
 	print 'Text: ', $paragraph->text, "\n", "\n";
 }

 while ( defined( my $sentence = $dump_file->sentences->next ) ) {
 	print 'Id: ',   $sentence->attribute( 'id' ), "\n";
 	print 'Id: ',   $sentence->id, "\n";
 	print 'Name: ', $sentence->name, "\n";
 	print 'Text: ', $sentence->text, "\n", "\n";
 }

 ###

 while ( defined( my $text = $dump_file->texts->next ) ) {
 	print 'Id: ',   $text->attribute( 'id' ), "\n";
 	print 'Id: ',   $text->id, "\n";
 	print 'Name: ', $text->name, "\n";
 	print 'Text: ', $text->text, "\n", "\n";

 	my @paragraphs = $text->get_elements( 'paragraphs/paragraph' );

 	foreach my $paragraph ( @paragraphs ) {
 		print 'Id: ',   $paragraph->attribute( 'id' ), "\n";
 		print 'Id: ',   $paragraph->id, "\n";
 		print 'Name: ', $paragraph->name, "\n";
 		print 'Text: ', $paragraph->text, "\n", "\n";

 		my @sentences = $paragraph->get_elements( 'sentence' );

 		foreach my $sentence ( @sentences ) {
 			print 'Id: ',   $sentence->attribute( 'id' ), "\n";
 			print 'Id: ',   $sentence->id, "\n";
 			print 'Name: ', $sentence->name, "\n";
 			print 'Text: ', $sentence->text, "\n", "\n";
 		}
 	}
 }

=head1 METHODS

=head2 texts

Sets iterator to <text> elements.
Returns C<$self> to allow chaining: C<< $self->texts->next >>.

=head2 paragraphs

Sets iterator to <paragraph> elements.
Returns C<$self> to allow chaining: C<< $self->paragraphs->next >>.

=head2 sentences

Sets iterator to <sentence> elements.
Returns C<$self> to allow chaining: C<< $self->sentences->next >>.

=head2 next

Returns next L<XML::TreePuller::Element|http://search.cpan.org/~triddle/XML-TreePuller-0.1.2/lib/XML/TreePuller.pm#XML::TreePuller::Element> with added convenience method 'id', so you can get 'id' attribute with:
C<< $paragraph->id >> instead of C<< $paragraph->attribute('id') >>.

=head1 PERFORMANCE

Read L<performance section|http://search.cpan.org/~triddle/XML-TreePuller-0.1.2/lib/XML/TreePuller.pm#IMPROVING_PERFORMANCE> of the L<underlying|http://search.cpan.org/~triddle/XML-TreePuller-0.1.2/lib/XML/TreePuller.pm> package.

=head1 AUTHOR

L<OpenCorpora.org|http://opencorpora.org> team.

=head1 LICENSE

This program is free software, you can redistribute it under the same terms as Perl itself.
