package Bio::PanGenome::Output::GroupTabFiles;

# ABSTRACT: Take in an array of files and output raw tab files for analysis by R to turn into plots


use Moose;
use Bio::PanGenome::GroupStatistics;
use Bio::PanGenome::Output::NumberNewGroups;
use Bio::PanGenome::Output::NumberUniqueGroups;
use Bio::PanGenome::Output::NumberTotalGroups;
use Bio::PanGenome::Output::NumberConservedGroups;

has 'group_statistics_obj'      => ( is => 'ro', isa => 'Bio::PanGenome::GroupStatistics',        required => 1 );

sub create_output_files
{
  my ($self) = @_;
  
  Bio::PanGenome::Output::NumberNewGroups->new( 
    group_statistics_obj => $self->group_statistics_obj  
    )->create_raw_output_file();
    
  Bio::PanGenome::Output::NumberUniqueGroups->new( 
    group_statistics_obj => $self->group_statistics_obj  
    )->create_raw_output_file();

  Bio::PanGenome::Output::NumberTotalGroups->new( 
    group_statistics_obj => $self->group_statistics_obj  
    )->create_raw_output_file();

  Bio::PanGenome::Output::NumberConservedGroups->new( 
    group_statistics_obj => $self->group_statistics_obj  
    )->create_raw_output_file();

}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

Bio::PanGenome::Output::GroupTabFiles - Take in an array of files and output raw tab files for analysis by R to turn into plots

=head1 VERSION

version 1.133090

=head1 SYNOPSIS

Take in an array of files and output raw tab files for analysis by R to turn into plots
   use Bio::PanGenome::Output::GroupTabFiles;

   my $obj = Bio::PanGenome::Output::NumberUniqueGroups->new(
     group_statistics_obj => $group_statistics
   );

   $obj->create_output_files();

=head1 AUTHOR

Andrew J. Page <ap13@sanger.ac.uk>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Wellcome Trust Sanger Institute.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
