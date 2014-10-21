package Bio::PanGenome::Output::GroupMultifasta;

# ABSTRACT:  Take in a group and create a multifasta file


use Moose;
use Bio::SeqIO;
use Bio::PanGenome::Exceptions;
use Bio::PanGenome::AnalyseGroups;

has 'group_name'           => ( is => 'ro', isa => 'Str',                           required => 1 );
has 'analyse_groups'       => ( is => 'ro', isa => 'Bio::PanGenome::AnalyseGroups', required => 1 );
has 'output_filename_base' => ( is => 'ro', isa => 'Str',                           default  => 'output_groups' );
has '_genes'         => ( is => 'ro', isa  => 'ArrayRef', lazy    => 1, builder => '_build__genes' );
has '_output_seq_io' => ( is => 'ro', lazy => 1,          builder => '_build__output_seq_io' );

sub _build__output_seq_io {
    my ($self) = @_;
    my $output_name = $self->output_filename_base . '_' . $self->group_name;
    $output_name =~ s!\W!_!g;
    $output_name .= '.fa';
    return Bio::SeqIO->new( -file => ">" . $output_name, -format => 'Fasta' );
}

sub _build__genes {
    my ($self) = @_;
    return $self->analyse_groups->_groups_to_genes->{ $self->group_name };
}

sub _lookup_sequence {
    my ( $self, $gene, $filename ) = @_;
    return undef if(! defined($filename));
    open(my $fh, '-|', 'fasta_grep -f '.$filename. ' '.$gene);
    my $fasta_obj = Bio::SeqIO->new( -fh => $fh, -format => 'Fasta' );
    while ( my $seq = $fasta_obj->next_seq() ) {
        next unless ( $seq->display_id eq $gene );
        return $seq;
    }
    return undef;
}

sub create_file {
    my ($self) = @_;

    for my $gene ( @{ $self->_genes } ) {
        my $seq = $self->_lookup_sequence( $gene, $self->analyse_groups->_genes_to_file->{$gene} );
        next unless ( defined($seq) );
        $self->_output_seq_io->write_seq($seq);
    }

    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

Bio::PanGenome::Output::GroupMultifasta - Take in a group and create a multifasta file

=head1 VERSION

version 1.133090

=head1 SYNOPSIS

Take in a group and create a multifasta file
   use Bio::PanGenome::Output::GroupMultifasta;

   my $obj = Bio::PanGenome::Output::GroupMultifasta->new(
       group_name      => 'aaa',
       analyse_groups  => $analyse_groups,
       output_filename_base => 'abc'
     );
   $obj->create_file();

=head1 AUTHOR

Andrew J. Page <ap13@sanger.ac.uk>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Wellcome Trust Sanger Institute.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
