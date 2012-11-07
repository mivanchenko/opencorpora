#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use DumpFile;

my $file_name =
	'test.xml'
#	'annot.opcorpora.xml'
;

my $dump_file = DumpFile->new( file_name => $file_name );

while ( defined( my $text = $dump_file->texts->next ) ) {
	print 'Id: ',   $text->attribute( 'id' ), "\n";
	print 'Name: ', $text->name, "\n";
	print 'Text: ', $text->text, "\n";
	print "\n";
}
