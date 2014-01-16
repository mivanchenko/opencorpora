package DumpFile;

use strict;
use warnings;

use DumpFile::Struct;
use XML::TreePuller;

use version; our $VERSION = qv('1.0');

$| = 1;  # I/O buffer off
binmode( STDOUT, ':encoding(utf8)' );

our %XPATHS = (
	'text'      => '/annotation/text',
	'paragraph' => '/annotation/text/paragraphs/paragraph',
	'sentence'  => '/annotation/text/paragraphs/paragraph/sentence',
);

# { text_id } - { tag_name } - [ tag_values ]
my %TAGS;

my $TAGS_PREPROCESSED = 0;

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
	$self->_do_init();
}

sub _do_init {
	my ($self) = @_;

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
	my ($self, $context) = @_;
	my $next = $self->iterator->next;

	unless ( $next ) {
		return;
	}

	# add methods to 'next element'
	{
		# subs must be redefined
		no warnings 'redefine';

		# method 'id'
		*XML::TreePuller::Element::id = sub {
			return $next->attribute( 'id' );
		};

		# method 'struct'
		# returns hash structure for a given element
		*XML::TreePuller::Element::struct = sub {
			return
				DumpFile::Struct->new(
					'element'  => $next,
					'all_tags' => \%TAGS,
					'tags_preprocessed' => $TAGS_PREPROCESSED,
				)->struct( $context );
		};
	}

	return $next;
}

sub preprocess_tags {
	my ($self) = @_;

	while ( defined( my $text = $self->texts->next( 'tags' ) ) ) {
		my $text_struct = $text->struct;

		while ( my ($k, $v) = each %{$text_struct} ) {
			$TAGS{ $k } = $v;
		}
	}

	# reset reader cursor
	$self->_do_init();

	$TAGS_PREPROCESSED = 1;

	return 1;
}

1;

__END__

=head1 NAME

DumpFile - Iterator for L<OpenCorpora|http://opencorpora.org>'s L<XML dump file|http://opencorpora.org/?page=downloads>.

=head1 SYNOPSIS

=head2 General

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

=head2 Accessing tags

 use DumpFile;

 my $dump_file = DumpFile->new( file_name => 'annot.opcorpora.xml' );

 while ( defined( my $text = $dump_file->texts->next ) ) {
 	my $text_struct = $text->struct;

 	# <tags>
 	#   <tag>url:opencorpora.org</tag>
 	#   <tag>url:opencorpora.org - 2</tag>
 	# </tags>
 	print $text_struct->{'tags'}{'url'}[0];  # should print 'opencorpora.org'
 }

=head2 Tags preprocessing

 use DumpFile;

 my $dump_file = DumpFile->new( file_name => 'annot.opcorpora.xml' );

 $dump_file->preprocess_tags();

 while ( defined( my $text = $dump_file->texts->next ) ) {
 	my $text_struct = $text->struct;
 	print Dumper $text_struct;
 }

=head2 Old school

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
C<< $next_element->id >> instead of C<< $next_element->attribute('id') >>.

=head2 preprocess_tags

Reads entire XML collecting all the tags from texts. This collection is later used for tags inheritance, where the child tag inherits all the tags from all its parents.

=head1 PERFORMANCE

Read L<performance section|http://search.cpan.org/~triddle/XML-TreePuller-0.1.2/lib/XML/TreePuller.pm#IMPROVING_PERFORMANCE> of the L<underlying|http://search.cpan.org/~triddle/XML-TreePuller-0.1.2/lib/XML/TreePuller.pm> package.

=head1 AUTHOR

L<OpenCorpora.org|http://opencorpora.org> team.

=head1 BUGS

Please, report bugs to:

=pod

C<< print grep$_=pack((chr hex oct 77),hex),unpack join(undef,((chr hex oct 51).(chr hex oct 40))x oct hex 29),unpack chr(hex oct 104).chr hex((chr hex oct 40).(chr hex oct 75)),pack chr(hex oct 52).chr hex((chr hex oct 40).(chr hex oct 75)),unpack chr(hex oct 104).chr hex((chr hex oct 40).(chr hex oct 75)),pack chr(hex oct 60).chr hex((chr hex oct 40).(chr hex oct 75)),'011010011001101100101001110110010011100101001001101010011101100101111001111110011101000111101001011010010011100101001001001010011010100111001001110100011011101111111001000110110111100100001000101110011110100100101001011010011100100111010001001110011111100111101001' >>

=cut

=head1 LICENSE

This program is free software, you can redistribute it under the same terms as Perl itself.
