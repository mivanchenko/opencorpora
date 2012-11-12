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

__END__

=head1 NAME

DumpFile::Struct - Helper package for DumpFile.

=head1 METHODS

=head2 struct

Returns DumpFile instance as a hashref for easy access to its children, including all the attributes and element names.
Instead of looping via C<< $element->get_elements() >>, you can just say C<< $text->{'paragraphs'}[2]{'sentences'}[3]{'tokens'}[5]{'revisions'}[10]{'text'} >>.

=head1 AUTHOR

L<OpenCorpora.org|http://opencorpora.org> team.

=head1 LICENSE

This program is free software, you can redistribute it under the same terms as Perl itself.
