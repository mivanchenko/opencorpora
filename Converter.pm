package Converter;

use strict;
use warnings;

use Carp;
use DBI;
use XML::LibXML::Reader;

$| = 1; # I/O buffer off
binmode( STDOUT, ':encoding(utf8)' );


use Object::InsideOut;

my @file_name :Arg( 'Name' => 'file_name', 'Default' => 'test.xml' )
              :Field :Acc( file_name );

my @db_name :Arg( 'Name' => 'db_name', 'Default' => 'corpus.sqlite' )
            :Field :Acc( db_name );


sub xml2sqlite {
	my ($self) = @_;
	my ($file_name, $db_name) = ( $self->file_name, $self->db_name );

	my $reader = XML::LibXML::Reader->new( location => $file_name )
		or confess "Cannot read [$file_name]: [$!]\n";

	my $dbh = DBI->connect( 'dbi:SQLite:dbname=' . $db_name );

	$self->_prepare_tables( $dbh );

	while ( $reader->read ) {
		# skip other elements
		if ( $reader->name ne 'text' ) {
			next;
		}

		# skip closing tag
		if ( $reader->nodeType == XML_READER_TYPE_END_ELEMENT ) {
			next;
		}

		$self->_save_text( $reader, $dbh );
	}

	$dbh->disconnect;

	return 1;
}

sub _prepare_tables {
	my ($self, $dbh) = @_;

	$dbh->do( q{
		DROP TABLE IF EXISTS texts
	});

	$dbh->do( q{
		DROP TABLE IF EXISTS paragraphs
	});

	$dbh->do( q{
		CREATE TABLE IF NOT EXISTS texts
		( text_id INTEGER, text TEXT )
	});

	$dbh->do( q{
		CREATE TABLE IF NOT EXISTS paragraphs
		( paragraph_id INTEGER, text_id INTEGER, paragraph TEXT )
	});

	return 1;
}

sub _save_text {
	my ($self, $reader, $dbh) = @_;

	my $text_id  = $reader->getAttribute( 'id' );
	my $text_xml = $reader->readOuterXml;

	my $query = qq{
		INSERT INTO texts VALUES ( ?, ? )
	};

	$dbh->do( $query, undef, $text_id, $text_xml );
#	print 't';

	$self->_save_paragraphs( $dbh, $text_id, $text_xml );

	return 1;
}

sub _save_paragraphs {
	my ($self, $dbh, $text_id, $text_xml) = @_;
	my @paragraphs;
	my $fields_count = 3;

	my $reader = XML::LibXML::Reader->new( string => $text_xml );

	while ( $reader->read ) {
		# skip other elements
		if ( $reader->name ne 'paragraph' ) {
			next;
		}

		# skip closing tag
		if ( $reader->nodeType == XML_READER_TYPE_END_ELEMENT ) {
			next;
		}

		my $paragraph_id  = $reader->getAttribute( 'id' );
		my $paragraph_xml = $reader->readOuterXml;

		# have you updated $fields_count?
		push @paragraphs, $paragraph_id, $text_id, $paragraph_xml;

#		print 'p';
	}

	# text w/o paragraphs
	unless ( @paragraphs ) {
		return;
	}

	my $rows_mask = $self->_generate_rows_mask( \@paragraphs, 3 );

	my $query = qq{
		INSERT INTO paragraphs VALUES $rows_mask
	};

	$dbh->do( $query, undef, @paragraphs );

	return 1;
}

# ( [1, 2], [3, 4], [5, 6] ) --> (?, ?), (?, ?), (?, ?)
sub _generate_rows_mask {
	my ($self, $rows, $fields_count) = @_;

	my $rows_count   = scalar( @{$rows} ) / $fields_count;
	my $fields_mask = '(' . join( ', ', ('?') x $fields_count ) . ')';
	my $rows_mask   = join( ', ', ($fields_mask) x $rows_count );

	return $rows_mask;
}

1;
