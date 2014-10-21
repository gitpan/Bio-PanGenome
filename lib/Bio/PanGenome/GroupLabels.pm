package Bio::PanGenome::GroupLabels;

# ABSTRACT: Add labels to the groups


use Moose;
use Bio::PanGenome::Exceptions;

has 'groups_filename' => ( is => 'ro', isa => 'Str', required => 1 );
has 'output_filename' => ( is => 'ro', isa => 'Str', default  => 'labelled_groups_file' );

has '_input_fh'             => ( is => 'ro', lazy => 1,     builder => '_build__input_fh' );
has '_output_fh'            => ( is => 'ro', lazy => 1,     builder => '_build__output_fh' );
has '_group_default_prefix' => ( is => 'ro', isa  => 'Str', default => 'group_' );

sub _build__input_fh {
    my ($self) = @_;
    open( my $fh, $self->groups_filename )
      or Bio::PanGenome::Exceptions::FileNotFound->throw( error => "Group file not found:" . $self->groups_filename );
    return $fh;
}

sub _build__output_fh {
    my ($self) = @_;
    open( my $fh, '>', $self->output_filename )
      or Bio::PanGenome::Exceptions::CouldntWriteToFile->throw(
        error => "Couldnt write output file:" . $self->output_filename );
    return $fh;
}

sub add_labels {
    my ($self) = @_;

    my $counter = 1;
    my $in_fh   = $self->_input_fh;
    while (<$in_fh>) {
        my $line = $_;
        next if ( $line eq "" );
        print { $self->_output_fh } $self->_group_default_prefix . $counter . ": " . $line;
        $counter++;
    }
    close( $self->_input_fh );
    close( $self->_output_fh );
    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

Bio::PanGenome::GroupLabels - Add labels to the groups

=head1 VERSION

version 1.133090

=head1 SYNOPSIS

Add labels to the groups
   use Bio::PanGenome::GroupLabels;

   my $obj = Bio::PanGenome::GroupLabels->new(
     groups_filename   => 'abc.groups',
     output_filename => 'output.groups'
   );
   $obj->add_labels;

=head1 AUTHOR

Andrew J. Page <ap13@sanger.ac.uk>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Wellcome Trust Sanger Institute.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
