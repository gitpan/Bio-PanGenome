package Bio::PanGenome::InflateClusters;

# ABSTRACT: Take the clusters file from cd-hit and use it to inflate the output of MCL


use Moose;
use Bio::PanGenome::Exceptions;
with 'Bio::PanGenome::ClustersRole';

has 'mcl_filename'      => ( is => 'ro', isa => 'Str', required => 1 );
has 'output_file'       => ( is => 'ro', isa => 'Str', default  => 'inflated_results' );
has '_mcl_fh'           => ( is => 'ro',lazy => 1, builder => '_build__mcl_fh' );
has '_output_fh'        => ( is => 'ro',lazy => 1, builder => '_build__output_fh' );
has 'cdhit_groups_filename'  => ( is => 'ro', isa => 'Maybe[Str]' );

sub _build__output_fh
{
  my($self) = @_;
  open(my $fh, '>', $self->output_file) or Bio::PanGenome::Exceptions::CouldntWriteToFile->throw( error => 'Cant write to file: ' . $self->output_file );
  return $fh;
}

sub _build__mcl_fh
{
   my($self) = @_;
   open(my $fh, $self->mcl_filename) or Bio::PanGenome::Exceptions::FileNotFound->throw( error => 'Cant open file: ' . $self->mcl_filename );
   return $fh;
}

sub _inflate_line
{
   my($self, $line) = @_;
   my @inflated_genes;
   chomp($line);
   my @gene_names = split(/[\t\s]+/, $line);
   for my $gene_name (@gene_names)
   {
     push(@inflated_genes, $self->_inflate_gene($gene_name));
   }
   return join(' ',@inflated_genes);
}

sub _inflate_gene
{
   my($self, $gene_name) = @_;
   my $inflated_gene = $gene_name;
   if(defined($self->_clustered_genes->{$gene_name}))
   {
     $inflated_gene = $inflated_gene."\t". join("\t",@{$self->_clustered_genes->{$gene_name}});     
     delete($self->_clustered_genes->{$gene_name});
   }
   return $inflated_gene;
}

sub inflate
{
  my($self) = @_;
  my $mcl_fh = $self->_mcl_fh;
  
  # Inflate genes from cdhit which were sent to mcl
  while(<$mcl_fh>)
  {
    my $line = $_;
    print { $self->_output_fh } $self->_inflate_line($line) . "\n";
  }
  
  # Inflate any clusters that were in the clusters file but not sent to mcl
  for my $gene_name(keys %{$self->_clustered_genes})
  {
    next unless(defined($self->_clustered_genes->{$gene_name}));
    print { $self->_output_fh } $gene_name."\t". join("\t",@{$self->_clustered_genes->{$gene_name}})."\n";
  }
  
  if(defined($self->cdhit_groups_filename))
  {
    # Add clusters which were excluded because the groups were full at the cdhit stage
    open(my $cdhit_fh, $self->cdhit_groups_filename);
    while(<$cdhit_fh>)
    {
      print { $self->_output_fh } $_;
    }
  }
  
  close($self->_output_fh);
  1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

Bio::PanGenome::InflateClusters - Take the clusters file from cd-hit and use it to inflate the output of MCL

=head1 VERSION

version 1.133090

=head1 SYNOPSIS

Take the clusters file from cd-hit and use it to inflate the output of MCL
   use Bio::PanGenome::InflateClusters;

   my $obj = Bio::PanGenome::InflateClusters->new(
     clusters_filename  => 'example.clstr',
     mcl_filename       => 'example.mcl',
     output_file        => 'example.output'
   );
   $obj->inflate;

=head1 AUTHOR

Andrew J. Page <ap13@sanger.ac.uk>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Wellcome Trust Sanger Institute.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
