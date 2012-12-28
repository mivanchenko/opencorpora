use strict;
use warnings;

use DumpFile '1.0';
use Test::More tests => 1;

my $dump_file = DumpFile->new( file_name => 't/01inherit.test.xml' );

$dump_file->preprocess_tags();

while ( defined( my $text = $dump_file->texts->next ) ) {
	my $text_struct = $text->struct;

	if ( $text->id == 2 ) {
		is_deeply(
			$text_struct->{'tags'}{'url'},
			[qw( http://www.a.com http://www.a1.com )],
			'tags inheritance works'
		);
	}
}
