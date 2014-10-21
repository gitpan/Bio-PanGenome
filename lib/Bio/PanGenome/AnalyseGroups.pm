package Bio::PanGenome::AnalyseGroups;

# ABSTRACT: Take in a groups file and the original FASTA files and create plots and stats


use Moose;
use Bio::PanGenome::Exceptions;
use Bio::PanGenome::Plot::FreqOfGenes;

has 'fasta_files'          => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'groups_filename'      => ( is => 'ro', isa => 'Str',      required => 1 );
has 'output_filename'      => ( is => 'ro', isa => 'Str',      default  => 'summary_of_groups' );
has 'output_plot_filename' => ( is => 'ro', isa => 'Str',      default  => 'freq_of_genes.png' );

has '_number_of_isolates'  => ( is => 'ro', isa => 'Int', lazy => 1, builder => '_builder__number_of_isolates' );
has '_genes_to_file'       => ( is => 'rw', isa => 'HashRef' );
has '_files_to_genes'      => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_builder__files_to_genes' );
has '_freq_groups_per_genome' =>
  ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_builder__freq_groups_per_genome' );
has '_groups_to_genes'     => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_builder__groups_to_genes' );
has '_genes_to_groups'     => ( is => 'rw', isa => 'HashRef' );

has '_groups' => ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_builder__groups' );


sub BUILD {
    my ($self) = @_;
    # This triggers _genes_to_groups to be built
    $self->_groups_to_genes;
    # This triggers _genes_to_file to be buit
    $self->_files_to_genes;
}

sub _builder__groups
{
  my ($self) = @_;
  my @groups = sort keys %{$self->_groups_to_genes};
  return \@groups;
}

sub _builder__number_of_isolates {
    my ($self) = @_;
    return @{ $self->fasta_files };
}

sub _builder__files_to_genes {
    my ($self) = @_;
    my %files_to_genes;
    my %genes_to_file;
    for my $filename ( @{ $self->fasta_files } ) {
        open( my $fh, '-|', 'grep \> ' . $filename . ' | awk \'{print $1}\' | sed \'s/>//\' ' );
        while (<$fh>) {
            chomp;
            my $gene_name = $_;
            next if($gene_name eq "");
            push( @{ $files_to_genes{$filename} }, $gene_name );
            $genes_to_file{$gene_name} = $filename;
        }
        close($fh);
    }
    $self->_genes_to_file(\%genes_to_file);
    
    return \%files_to_genes;
}

sub _count_num_files_in_group {
    my ( $self, $genes ) = @_;
    my $count = 0;
    my %filename_freq;
    for my $gene ( @{$genes} ) {
        next if ( $gene eq "" );
        if ( defined( $self->_genes_to_file->{$gene} ) ) {
            $filename_freq{ $self->_genes_to_file->{$gene} }++;
        }
    }
    my @uniq_filenames = keys %filename_freq;
    return @uniq_filenames;
}

sub _builder__groups_to_genes {
    my ($self) = @_;
    my %groups_to_genes;
    my %genes_to_groups;

    open( my $fh, $self->groups_filename )
      or Bio::PanGenome::Exceptions::FileNotFound->throw( error => "Group file not found:" . $self->groups_filename );
    while (<$fh>) {
        chomp;
        my $line = $_;
        if ( $line =~ /^(.+): (.+)$/ ) {
            my $group_name = $1;
            my $genes      = $2;
            my @elements   = split( /[\s\t]+/, $genes );
            $groups_to_genes{$group_name} = \@elements;
            
            for my $gene (@elements) {
                $genes_to_groups{$gene} = $group_name;
            }
        }
    }
    $self->_genes_to_groups(\%genes_to_groups);
    
    return \%groups_to_genes;
}

sub _builder__freq_groups_per_genome {
    my ($self) = @_;
    my @group_count;

    open( my $fh, $self->groups_filename )
      or Bio::PanGenome::Exceptions::FileNotFound->throw( error => "Group file not found:" . $self->groups_filename );
    while (<$fh>) {
        chomp;
        my $line = $_;

        # Remove the group name
        $line =~ s!^(.+: )?!!;
        my @elements = split( /[\s\t]+/, $line );
        my $number_of_files_in_group = $self->_count_num_files_in_group( \@elements );
        $number_of_files_in_group = ( $number_of_files_in_group * 100 / $self->_number_of_isolates );
        push( @group_count, $number_of_files_in_group );

    }
    close($fh);
    my @sorted_group_count = sort { $b <=> $a } @group_count;
    return \@sorted_group_count;
}

sub create_plots {
    my ($self) = @_;

    my $plot_groups_obj =
      Bio::PanGenome::Plot::FreqOfGenes->new( freq_groups_per_genome => $self->_freq_groups_per_genome, output_filename => $self->output_plot_filename );
    $plot_groups_obj->create_plot();
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

Bio::PanGenome::AnalyseGroups - Take in a groups file and the original FASTA files and create plots and stats

=head1 VERSION

version 1.133090

=head1 SYNOPSIS

Take in a groups file and the original FASTA files and create plots and stats 
   use Bio::PanGenome::AnalyseGroups;

   my $plot_groups_obj = Bio::PanGenome::AnalyseGroups->new(
       fasta_files      => $fasta_files,
       groups_filename  => $groups_filename,
       output_filename  => $output_filename
     );
   $plot_groups_obj->create_plots();

=head1 AUTHOR

Andrew J. Page <ap13@sanger.ac.uk>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Wellcome Trust Sanger Institute.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
