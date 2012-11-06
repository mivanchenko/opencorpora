package Convertor;

use strict;
use warnings;

use Carp;
use Data::Dumper;
use DBI;
use XML::LibXML::Reader;

$| = 1; # I/O buffer off
binmode( STDOUT, ':encoding(utf8)' );


use Object::InsideOut;

my @file_name :Field :Acc( file_name )
	:Arg( 'Name' => 'file_name', 'Default' => 'test.xml' );

my @tag_name  :Field :Acc( tag_name )
	:Arg( 'Name' => 'tag_name',  'Default' => 'text' );

my @db_name   :Field :Acc( db_name )
	:Arg( 'Name' => 'db_name',   'Default' => 'corpus.sqlite' );


sub xml2sqlite {
	my ($self) = @_;
	my ($file_name, $tag_name, $db_name)
		= ( $self->file_name, $self->tag_name, $self->db_name );

	my $reader = XML::LibXML::Reader->new( location => $file_name )
		or confess "Cannot read [$file_name]: [$!]\n";

	my $dbh = DBI->connect( 'dbi:SQLite:dbname=' . $db_name );

	$dbh->do( q{
		DROP TABLE IF EXISTS texts
	});

	$dbh->do( q{
		CREATE TABLE IF NOT EXISTS texts ( text TEXT, text_id INTEGER )
	});

	while ( $reader->read ) {
		# skip other elements
		if ( $reader->name ne $tag_name ) {
			next;
		}

		# skip closing tag
		if ( $reader->nodeType == XML_READER_TYPE_END_ELEMENT ) {
			next;
		}

		$self->processNode( $reader, $dbh );
	}

	$dbh->disconnect;

	return 1;
}

sub processNode {
	my ($self, $reader, $dbh) = @_;
#	print $reader->name . "\n";
	print '.';

	my $text    = $reader->readOuterXml;
	my $text_id = $reader->getAttribute( 'id' );

	my $query = qq{
		INSERT INTO texts VALUES ( ?, ? )
	};

	$dbh->do( $query, undef, $text, $text_id );

	return 1;
}

1;
