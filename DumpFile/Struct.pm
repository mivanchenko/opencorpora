package DumpFile::Struct;

use strict;
use warnings;

sub new {
	my $class = shift;
	my $self = { @_ };
	bless $self, $class;
	return $self;
}

sub struct {
	my ($self) = @_;

	# $struct is a hash of properies: id, name, text,...
	my $struct = $self->_recursive_struct( $self->{'element'} );

	return $struct;
}

sub _recursive_struct {
	my ($self, $root) = @_;

	# get properties of current element
	my $struct = $root->attribute;
	$struct->{'text'} = $root->text;
	$struct->{'element_name'} = $root->name;

	# get properties of inner elements
	foreach my $elem ( $root->get_elements ) {
		push @{ $struct->{ $elem->name } }, $self->_recursive_struct( $elem );
	}
	
	return $struct;
}

1;
