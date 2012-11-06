#!/usr/bin/env perl

use strict;
use warnings;

use Convertor;

use Time::HiRes qw( gettimeofday tv_interval );
my $t0 = [gettimeofday];

my $conv = Convertor->new(
	'file_name' => 'test.xml',
#	'file_name' => 'annot.opcorpora.xml',
);
$conv->xml2sqlite();

print "\n" . tv_interval( $t0 ) . " sec\n";
