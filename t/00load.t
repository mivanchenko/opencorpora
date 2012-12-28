use strict;
use warnings;

use Test::More tests => 2;

BEGIN { use_ok( 'DumpFile', 1.0 ) }

my $dump_file = DumpFile->new( file_name => 't/00load.test.xml' );

my $texts_found;

while ( defined( my $text = $dump_file->texts->next ) ) {
	$texts_found++;
}

ok( $texts_found, 'some texts are found' );
