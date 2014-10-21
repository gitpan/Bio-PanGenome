package Bio::PanGenome::Output::NumberOfGroups;

# ABSTRACT: Create raw output files of group counts for turning into plots


use Moose;
use List::Util qw(shuffle);

has 'group_statistics_obj' => ( is => 'ro', isa => 'Bio::PanGenome::GroupStatistics', required => 1 );
has 'number_of_iterations' => ( is => 'ro', isa => 'Int', lazy => 1, builder => '_build_number_of_iterations' );
has 'output_filename'                     => ( is => 'ro', isa => 'Str', default => 'number_of_new_genes.png' );
has 'output_raw_filename_conserved_genes' => ( is => 'ro', isa => 'Str', default => 'number_of_conserved_genes.tab' );
has 'output_raw_filename_unique_genes'    => ( is => 'ro', isa => 'Str', default => 'number_of_unique_genes.tab' );
has 'output_raw_filename_total_genes' => ( is => 'ro', isa => 'Str', default => 'number_of_genes_in_pan_genome.tab' );
has 'output_raw_filename_new_genes'   => ( is => 'ro', isa => 'Str', default => 'number_of_new_genes.tab' );
has '_conserved_genes' => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );
has '_unique_genes' => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );
has '_total_genes'  => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );
has '_new_genes'    => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );

sub _build_number_of_iterations
{
   my ($self) = @_;
   my $number_of_iterations = 100;
   my $number_of_files = @{ $self->group_statistics_obj->_sorted_file_names  };
   if($number_of_files > $number_of_iterations)
   {
     $number_of_iterations = $number_of_files;
   }
   return $number_of_iterations;
}

sub create_output_files {
    my ($self) = @_;

    for ( my $i = 0 ; $i < $self->number_of_iterations ; $i++ ) {
            $self->_single_iteration_gene_expansion;
    }

    $self->_create_raw_output_file( $self->output_raw_filename_conserved_genes, $self->_conserved_genes );
    $self->_create_raw_output_file( $self->output_raw_filename_unique_genes,    $self->_unique_genes );
    $self->_create_raw_output_file( $self->output_raw_filename_total_genes,     $self->_total_genes );
    $self->_create_raw_output_file( $self->output_raw_filename_new_genes,       $self->_new_genes );
    return 1;
}

sub _create_raw_output_file {
    my ( $self, $filename, $output_data ) = @_;
    open( my $fh, '>', $filename );
    for my $iterations ( @{$output_data} ) {
        print {$fh} join( "\t", @{$iterations} );
        print {$fh} "\n";
    }
    close($fh);
}

sub _shuffle_input_files {
    my ($self) = @_;
    my @shuffled_input_files = shuffle( @{ $self->group_statistics_obj->_sorted_file_names } );
    return \@shuffled_input_files;
}

sub _single_iteration_gene_expansion {
    my ($self) = @_;
    my %existing_groups;
    my @conserved_genes_added_per_file;
    my @unique_genes_added_per_file;
    my @total_genes_added_per_file;
    my @new_genes_added_per_file;

    my $shuffled_input_files = $self->_shuffle_input_files();

    my $files_counter = 1;
    for my $input_file ( @{$shuffled_input_files} ) {
        my $unique_groups_counter    = 0;
        my $total_groups_counter     = 0;
        my $new_group_counter        = 0;
        my $conserved_groups_counter = 0;
        my $new_groups               = $self->group_statistics_obj->_files_to_groups->{$input_file};

        for my $group ( @{$new_groups} ) {
            if ( !defined( $existing_groups{$group} ) ) {
                $new_group_counter++;
            }
            $existing_groups{$group}++;
        }

        for my $group ( keys %existing_groups ) {
            if ( $existing_groups{$group} == $files_counter ) {
                $conserved_groups_counter++;
            }

            if ( $existing_groups{$group} == 1 ) {
                $unique_groups_counter++;
            }
            $total_groups_counter++;
        }

        push( @conserved_genes_added_per_file, $conserved_groups_counter );
        push( @unique_genes_added_per_file,    $unique_groups_counter );
        push( @total_genes_added_per_file,     $total_groups_counter );
        push( @new_genes_added_per_file,       $new_group_counter );
        $files_counter++;
    }
    push( @{ $self->_conserved_genes }, \@conserved_genes_added_per_file );
    push( @{ $self->_unique_genes },    \@unique_genes_added_per_file );
    push( @{ $self->_total_genes },     \@total_genes_added_per_file );
    push( @{ $self->_new_genes },       \@new_genes_added_per_file );

    return;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

Bio::PanGenome::Output::NumberOfGroups - Create raw output files of group counts for turning into plots

=head1 VERSION

version 1.133090

=head1 SYNOPSIS

# ABSTRACT: Create raw output files of group counts for turning into plots
use Bio::PanGenome::Output::NumberOfGroups;

my $obj = Bio::PanGenome::Output::NumberOfGroups->new(
    group_statistics_obj => $group_stats
  );
$obj->create_files();

=head1 AUTHOR

Andrew J. Page <ap13@sanger.ac.uk>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Wellcome Trust Sanger Institute.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
