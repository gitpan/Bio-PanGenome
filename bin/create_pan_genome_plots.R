#!/software/pathogen/external/apps/usr/local/bin/Rscript
# ABSTRACT: Create R plots
# PODNAME: create_plots.R

# Take the output files from the pan genome pipeline and create nice plots.

mydata = read.table("number_of_new_genes.tab")
boxplot(mydata, data=mydata, main="Number of new genes",
         xlab="Number of genomes", ylab="Number of genes",varwidth=TRUE, ylim=c(0,max(mydata)), outline=FALSE)

mydata = read.table("number_of_conserved_genes.tab")
boxplot(mydata, data=mydata, main="Number of conserved genes",
          xlab="Number of genomes", ylab="Number of genes",varwidth=TRUE, ylim=c(0,max(mydata)), outline=FALSE)
 
mydata = read.table("number_of_genes_in_pan_genome.tab")
boxplot(mydata, data=mydata, main="Number of genes in the pan-genome",
          xlab="Number of genomes", ylab="Number of genes",varwidth=TRUE, ylim=c(0,max(mydata)), outline=FALSE)

mydata = read.table("number_of_unique_genes.tab")
boxplot(mydata, data=mydata, main="Number of unique genes",
         xlab="Number of genomes", ylab="Number of genes",varwidth=TRUE, ylim=c(0,max(mydata)), outline=FALSE)

__END__

=pod

=head1 NAME

create_plots.R - Create R plots

=head1 VERSION

version 1.133090

=head1 AUTHOR

Andrew J. Page <ap13@sanger.ac.uk>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Wellcome Trust Sanger Institute.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
