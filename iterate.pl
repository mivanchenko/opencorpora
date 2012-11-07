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
	print 'Text: ', $text->text, "\n", "\n";

	my @paragraphs = $text->get_elements( 'paragraphs/paragraph' );

	foreach my $paragraph ( @paragraphs ) {
		print 'Id: ',   $paragraph->attribute( 'id' ), "\n";
		print 'Name: ', $paragraph->name, "\n";
		print 'Text: ', $paragraph->text, "\n", "\n";

		my @sentences = $paragraph->get_elements( 'sentence' );

		foreach my $sentence ( @sentences ) {
			print 'Id: ',   $sentence->attribute( 'id' ), "\n";
			print 'Name: ', $sentence->name, "\n";
			print 'Text: ', $sentence->text, "\n", "\n";
		}
	}
}

#while ( defined( my $text = $dump_file->texts->next ) ) {
#	print 'Id: ',   $text->attribute( 'id' ), "\n";
#	print 'Name: ', $text->name, "\n";
#	print 'Text: ', $text->text, "\n", "\n";
#}
#
#while ( defined( my $paragraph = $dump_file->paragraphs->next ) ) {
#	print 'Id: ',   $paragraph->attribute( 'id' ), "\n";
#	print 'Name: ', $paragraph->name, "\n";
#	print 'Text: ', $paragraph->text, "\n", "\n";
#}
#
#while ( defined( my $sentence = $dump_file->sentences->next ) ) {
#	print 'Id: ',   $sentence->attribute( 'id' ), "\n";
#	print 'Name: ', $sentence->name, "\n";
#	print 'Text: ', $sentence->text, "\n", "\n";
#}
