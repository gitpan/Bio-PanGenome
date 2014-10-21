package Bio::PanGenome::Output::DifferenceBetweenSets;

# ABSTRACT:  Given two sets of isolates and a group file, output whats unique in each and whats in common


use Moose;
use Bio::SeqIO;
use Bio::PanGenome::Exceptions;
use Bio::PanGenome::AnalyseGroups;
use Bio::PanGenome::Output::QueryGroups;

has 'analyse_groups'       => ( is => 'ro', isa => 'Bio::PanGenome::AnalyseGroups', required => 1 );
has 'input_filenames_sets' => ( is => 'ro', isa => 'ArrayRef[ArrayRef]',            required => 1 );
has 'output_filename_base' => ( is => 'ro', isa => 'Str',                           default  => 'set_difference' );

has '_query_groups_objs' => ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build__query_groups_objs' );

# TODO: update to handle more than 2 input sets

sub _build__query_groups_objs {
    my ($self) = @_;
    my @query_groups_objs;
    for my $file_name_set ( @{ $self->input_filenames_sets } ) {
        push(
            @query_groups_objs,
            Bio::PanGenome::Output::QueryGroups->new(
                analyse_groups  => $self->analyse_groups,
                input_filenames => $file_name_set
            )
        );
    }
    
    my @all_input_files = (@{ $self->input_filenames_sets->[0] },@{ $self->input_filenames_sets->[1] });
    push(
        @query_groups_objs,
        Bio::PanGenome::Output::QueryGroups->new(
            analyse_groups  => $self->analyse_groups,
            input_filenames => \@all_input_files
        )
    );
    
    
    return \@query_groups_objs;
}

sub _subtract_arrays {
    my ( $self, $array_1, $array_2 ) = @_;
    my %array_1 = map { $_ => 1 } @{$array_1};
    my @difference = grep { not $array_1{$_} } @{$array_2};
    return \@difference;
}

sub _groups_unique {
    my ( $self, $output_filename, $query_group1, $query_group2 ) = @_;
    my $unique_groups = $self->_subtract_arrays( $query_group2->_groups, $query_group1->_groups  );
    $query_group1->groups_with_external_inputs( $output_filename, $unique_groups );
}

sub groups_set_one_unique_filename
{
  my ($self) = @_;
  return $self->output_filename_base . '_unique_set_one';
}

sub groups_set_two_unique_filename
{
  my ($self) = @_;
  return $self->output_filename_base . '_unique_set_two';
}

sub groups_in_common_filename
{
  my ($self) = @_;
  return $self->output_filename_base . '_common_set';
}


sub groups_set_one_unique {
    my ($self) = @_;
    $self->_groups_unique(
        $self->groups_set_one_unique_filename,
        $self->_query_groups_objs->[0],
        $self->_query_groups_objs->[1]
    );
}

sub groups_set_two_unique {
    my ($self) = @_;
    $self->_groups_unique(
        $self->groups_set_two_unique_filename,
        $self->_query_groups_objs->[1],
        $self->_query_groups_objs->[0]
    );
}

sub groups_in_common {
    my ($self) = @_;
    my $unique_group_1 = $self->_subtract_arrays( $self->_query_groups_objs->[0]->_groups, $self->_query_groups_objs->[1]->_groups );
    my $unique_group_2 = $self->_subtract_arrays( $self->_query_groups_objs->[1]->_groups, $self->_query_groups_objs->[0]->_groups );
    my $common_groups_1  = $self->_subtract_arrays(  $unique_group_1,$self->_query_groups_objs->[2]->_groups);
    my $common_groups_2  = $self->_subtract_arrays(  $unique_group_2,$common_groups_1);
    $self->_query_groups_objs->[2]->groups_with_external_inputs( $self->groups_in_common_filename, $common_groups_2  );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

Bio::PanGenome::Output::DifferenceBetweenSets - Given two sets of isolates and a group file, output whats unique in each and whats in common

=head1 VERSION

version 1.133090

=head1 SYNOPSIS

Given two sets of isolates and a group file, output whats unique in each and whats in common
   use Bio::PanGenome::Output::DifferenceBetweenSets;

   my $obj = Bio::PanGenome::Output::DifferenceBetweenSets->new(
       analyse_groups  => $analyse_groups,
       input_filenames_sets => 
       [
         ['aaa.faa','bbb.faa'],
         ['ccc.faa','ddd.faa']
       ],
     );
   $obj->groups_set_one_unique();
   $obj->groups_set_two_unique();
   $obj->groups_in_common();

=head1 AUTHOR

Andrew J. Page <ap13@sanger.ac.uk>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Wellcome Trust Sanger Institute.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
