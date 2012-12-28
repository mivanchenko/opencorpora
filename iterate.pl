#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
$Data::Dumper::Terse = 1;

use DumpFile '1.0';

my $file_name =
	't/00load.test.xml',
#	'test.xml'
#	'test2.xml'
#	'annot.opcorpora.xml'
;

my $dump_file = DumpFile->new( file_name => $file_name );

use Time::HiRes qw( gettimeofday tv_interval );
my $t0 = [gettimeofday];
print 'Preprocessing';

#$dump_file->preprocess_tags();

print " done\n";
print tv_interval( $t0 ) . " sec\n";
print 'Processing';

while ( defined( my $text = $dump_file->texts->next ) ) {
	my $text_struct = $text->struct;
	print Dumper $text_struct;
	print '.';
}

print " done\n";
print tv_interval( $t0 ) . " sec\n";


#while ( defined( my $p = $dump_file->paragraphs->next ) ) {
#	my $p_struct = $p->struct;
#	print 'Id:           ' . $p_struct->{'id'}           . "\n";
#	print 'Name:         ' . $p_struct->{'name'}         . "\n";
#	print 'Text:         ' . $p_struct->{'text'}         . "\n";
#	print 'Element name: ' . $p_struct->{'element_name'} . "\n";
#	print $p_struct->{'sentence'}[1]{'text'} . "\n";
#	last;
#}


## speed test
#use Time::HiRes qw( gettimeofday tv_interval );
#my $t0 = [gettimeofday];
#while ( defined( my $text = $dump_file->sentences->next ) ) {
##	my $text_struct = $text->struct;
#	print '.';
#}
#print "\n";
#print tv_interval( $t0 ) . " sec\n";



#while ( defined( my $paragraph = $dump_file->paragraphs->next ) ) {
#	print 'Id: ',   $paragraph->attribute( 'id' ), "\n";
#	print 'Id: ',   $paragraph->id, "\n";
#	print 'Name: ', $paragraph->name, "\n";
#	print 'Text: ', $paragraph->text, "\n", "\n";
#}
#
#while ( defined( my $sentence = $dump_file->sentences->next ) ) {
#	print 'Id: ',   $sentence->attribute( 'id' ), "\n";
#	print 'Id: ',   $sentence->id, "\n";
#	print 'Name: ', $sentence->name, "\n";
#	print 'Text: ', $sentence->text, "\n", "\n";
#}

#while ( defined( my $text = $dump_file->texts->next ) ) {
#	print 'Id: ',   $text->attribute( 'id' ), "\n";
#	print 'Id: ',   $text->id, "\n";
#	print 'Name: ', $text->name, "\n";
#	print 'Text: ', $text->text, "\n", "\n";
#
#	my @paragraphs = $text->get_elements( 'paragraphs/paragraph' );
#
#	foreach my $paragraph ( @paragraphs ) {
#		print 'Id: ',   $paragraph->attribute( 'id' ), "\n";
#		print 'Id: ',   $paragraph->id, "\n";
#		print 'Name: ', $paragraph->name, "\n";
#		print 'Text: ', $paragraph->text, "\n", "\n";
#
#		my @sentences = $paragraph->get_elements( 'sentence' );
#
#		foreach my $sentence ( @sentences ) {
#			print 'Id: ',   $sentence->attribute( 'id' ), "\n";
#			print 'Id: ',   $sentence->id, "\n";
#			print 'Name: ', $sentence->name, "\n";
#			print 'Text: ', $sentence->text, "\n", "\n";
#		}
#	}
#}

sub debug { print Dumper( shift ) }
