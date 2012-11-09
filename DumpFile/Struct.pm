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

	my $struct;

	###
	# get properties of current element

	# merge attributes hash into struct
	my $attrs = $root->attribute;
	foreach my $k ( keys %{$attrs} ) {
		$struct->{$k} = $attrs->{$k};
	}

	$struct->{'text'} = $root->text;
	$struct->{'element_name'} = $root->name;


	###
	# get properties of inner elements

	my @elems = $root->get_elements();

	# names of inner elements are keys of struct
	foreach my $elem ( @elems ) {
		# !!! recursion
		push @{ $struct->{ $elem->name } }, $self->_recursive_struct( $elem );
	}
	
	return $struct;
}

1;
