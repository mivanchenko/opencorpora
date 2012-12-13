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
	my ($self, $context) = @_;

	my $struct;

	if ( $context && $context eq 'tags' ) {
		# hash of text properies: id, parent, tags
		$struct = $self->_tags_struct( $self->{'element'} );
	}
	else {
		# hash of properies: id, name, text, etc. etc.
		$struct = $self->_recursive_struct( $self->{'element'} );
	}

	return $struct;
}

# Returns: { text_id } - { tag_name } - [ tag_values ]
sub _tags_struct {
	my ($self, $root) = @_;
	my $struct;

	# get properties of <tags>
	foreach my $elem ( $root->get_elements ) {
		$struct->{ $root->attribute( 'id' ) } = $self->_get_tags( $elem );
	}
	
	return $struct;
}

# get <tag>s content as hash of name:value pairs
sub _get_tags {
	my ($self, $root) = @_;

	my $struct;

	foreach my $elem ( $root->get_elements ) {
		my ($tag_name, $tag_value) = split /:/, $elem->text, 2;

		push @{ $struct->{ $tag_name } }, $tag_value;
	}
	
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

		unless ( $self->{'tags_preprocessed'} ) {
			if ( $elem->name eq 'tags' ) {
				$struct->{'tags'} = $self->_get_tags( $elem );
				next;
			}
		}

		push @{ $struct->{ $elem->name } }, $self->_recursive_struct( $elem );
	}

	if ( $struct->{'element_name'} eq 'text' ) {
		if ( $self->{'tags_preprocessed'} ) {

			# merge content by 'id' with content by 'parent_id'
			my $tags_by_id = $self->{'all_tags'}->{ $struct->{'id'} };
			my $tags_by_parent_id = $self->{'all_tags'}->{ $struct->{'parent'} };

			$struct->{'tags'} = $tags_by_id;

			while ( my ($k, $v) = each %{$tags_by_parent_id} ) {
				my %IN_DESCENDANTS = map { $_ => 1 } @{ $struct->{'tags'}{$k} };

				foreach my $parent_value ( reverse @{$v} ) {
					unless ( $IN_DESCENDANTS{ $parent_value } ) {
						unshift @{ $struct->{'tags'}->{$k} }, $parent_value;
					}
				}
			}
		}
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
