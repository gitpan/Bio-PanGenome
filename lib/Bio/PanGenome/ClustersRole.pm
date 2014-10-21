package Bio::PanGenome::ClustersRole;
# ABSTRACT: A role to read a clusters file from CD hit 


use Moose::Role;
use Bio::PanGenome::Exceptions;

has 'clusters_filename' => ( is => 'ro', isa => 'Str', required => 1 );
has '_clustered_genes'  => ( is => 'ro',lazy => 1, builder => '_build__clustered_genes' );
has '_clusters_fh'      => ( is => 'ro',lazy => 1, builder => '_build__clusters_fh' );

sub _build__clusters_fh
{
  my($self) = @_;
  open(my $fh, $self->clusters_filename) or Bio::PanGenome::Exceptions::FileNotFound->throw( error => 'Cant open file: ' . $self->clusters_filename );
  return $fh;
}

sub _build__clustered_genes
{
  my($self) = @_;
  my $fh = $self->_clusters_fh;
  my %clustered_genes ;

  my %raw_clusters;
  my $current_cluster_name;
  while(<$fh>)
  {
    my $line = $_;
    if($line =~ /^>(.+)$/)
    {
      $current_cluster_name = $1;
    }
    
    #>Cluster 5
    #0	4201aa, >6630_4#9_00008... *
    #1	4201aa, >6631_1#23_00379... at 100.00%    
        
    if($line =~ /[\d]+\t[\w]+, >(.+)\.\.\. (.+)$/)
    {
      my $gene_name = $1;
      my $identity  = $2;
      
      if($identity eq '*')
      {
        $raw_clusters{$current_cluster_name}{representative_gene_name} = $gene_name;
      }
      else
      {
        push(@{$raw_clusters{$current_cluster_name}{gene_names}}, $gene_name);
      }
    }
  }
  
  # iterate over the raw clusters and convert to a simple hash
  for my $cluster_name (keys %raw_clusters)
  {
    $clustered_genes{$raw_clusters{$cluster_name}{representative_gene_name}} = $raw_clusters{$cluster_name}{gene_names};
  }
  
  return \%clustered_genes;
}

1;

__END__

=pod

=head1 NAME

Bio::PanGenome::ClustersRole - A role to read a clusters file from CD hit 

=head1 VERSION

version 1.133090

=head1 SYNOPSIS

A role to read a clusters file from CD hit 
   with 'Bio::PanGenome::ClustersRole';

=head1 AUTHOR

Andrew J. Page <ap13@sanger.ac.uk>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Wellcome Trust Sanger Institute.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
