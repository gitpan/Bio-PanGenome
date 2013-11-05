package Bio::PanGenome::Output::GroupsMultifastas;

# ABSTRACT:  Take in a list of groups and create multifastas files for each group


use Moose;
use Bio::PanGenome::Exceptions;
use Bio::PanGenome::AnalyseGroups;
use Bio::PanGenome::Output::GroupMultifasta;

has 'group_names'          => ( is => 'ro', isa => 'ArrayRef',                      required => 1 );
has 'analyse_groups'       => ( is => 'ro', isa => 'Bio::PanGenome::AnalyseGroups', required => 1 );
has 'output_filename_base' => ( is => 'ro', isa => 'Str',                           default  => 'output_groups' );

sub create_files {
    my ($self) = @_;
    for my $group_name ( @{ $self->group_names } ) {
      # Check the group name exists
      next unless($self->analyse_groups->_groups_to_genes->{$group_name});    
        my $group_multifasta = Bio::PanGenome::Output::GroupMultifasta->new(
            group_name           => $group_name,
            analyse_groups       => $self->analyse_groups,
            output_filename_base => $self->output_filename_base
        );
        $group_multifasta->create_file;
    }
    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

Bio::PanGenome::Output::GroupsMultifastas - Take in a list of groups and create multifastas files for each group

=head1 VERSION

version 1.133090

=head1 SYNOPSIS

Take in a list of groups and create multifastas files for each group
   use Bio::PanGenome::Output::GroupsMultifastas;

   my $obj = Bio::PanGenome::Output::GroupsMultifastas->new(
       group_names      => ['aaa','bbb'],
       analyse_groups  => $analyse_groups
     );
   $obj->create_files();

=head1 AUTHOR

Andrew J. Page <ap13@sanger.ac.uk>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Wellcome Trust Sanger Institute.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
