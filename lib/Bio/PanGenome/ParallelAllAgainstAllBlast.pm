package Bio::PanGenome::ParallelAllAgainstAllBlast;

# ABSTRACT: Run all against all blast in parallel


use Moose;
use Bio::PanGenome::Exceptions;
use Bio::PanGenome::ChunkFastaFile;
use Bio::PanGenome::External::Makeblastdb;
use Bio::PanGenome::External::Blastp;
use Bio::PanGenome::External::Segmasker;
use Cwd;
use File::Temp;
use File::Basename;
with 'Bio::PanGenome::JobRunner::Role';

has 'fasta_file'              => ( is => 'ro', isa => 'Str',      required => 1 );
has 'blast_results_file_name' => ( is => 'ro', isa => 'Str',      lazy => 1, builder => '_build_blast_results_file_name' );
has 'makeblastdb_exec'        => ( is => 'ro', isa => 'Str',      default => 'makeblastdb' );
has 'blastp_exec'             => ( is => 'ro', isa => 'Str',      default => 'blastp' );
has 'segmasker_exec'          => ( is => 'ro', isa => 'Str',      default => 'segmasker' );
has '_chunk_fasta_file_obj'   => ( is => 'ro', isa => 'Bio::PanGenome::ChunkFastaFile', lazy => 1, builder => '_build__chunk_fasta_file_obj' );
has '_sequence_file_names'    => ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build__sequence_file_names' );
has '_makeblastdb_obj'        => ( is => 'ro', isa => 'Bio::PanGenome::External::Makeblastdb', lazy => 1, builder => '_build__makeblastdb_obj' );
has '_segmasker_obj'          => ( is => 'ro', isa => 'Bio::PanGenome::External::Segmasker', lazy => 1, builder => '_build__segmasker_obj' );
has '_blast_database'         => ( is => 'ro', isa => 'Str',      lazy => 1, builder => '_build__blast_database' );

has '_working_directory' =>
  ( is => 'ro', isa => 'File::Temp::Dir', default => sub { File::Temp->newdir( DIR => getcwd, CLEANUP => 1 ); } );
has '_working_directory_name' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build__working_directory_name' );

has '_memory_required_in_mb'  => ( is => 'ro', isa => 'Int',  lazy => 1, builder => '_build__memory_required_in_mb' );

sub _build__blast_database {
    my ($self) = @_;
    return $self->_makeblastdb_obj->output_database;
}

sub _build__segmasker_obj {
    my ($self) = @_;
    my $segmasker =
      Bio::PanGenome::External::Segmasker->new( fasta_file => $self->fasta_file, exec => $self->segmasker_exec, job_runner => $self->job_runner );
    $segmasker->run();
    return $segmasker;
}

sub _build__makeblastdb_obj {
    my ($self) = @_;
    my $blast_database =
      Bio::PanGenome::External::Makeblastdb->new( fasta_file => $self->fasta_file, exec => $self->makeblastdb_exec, mask_data => $self->_segmasker_obj->output_file, job_runner => $self->job_runner  );
    $blast_database->run();
    return $blast_database;
}

sub _build__chunk_fasta_file_obj {
    my ($self) = @_;
    return Bio::PanGenome::ChunkFastaFile->new( fasta_file => $self->fasta_file, );
}

sub _build__sequence_file_names {
    my ($self) = @_;
    return $self->_chunk_fasta_file_obj->sequence_file_names;
}

sub _build__working_directory_name {
    my ($self) = @_;
    return $self->_working_directory->dirname();
}

sub _build_blast_results_file_name {
    my ($self) = @_;
    return join( '/', ( $self->_working_directory_name, 'blast_results' ) );
}

sub _combine_blast_results {
    my ( $self, $output_files ) = @_;
    for my $output_file ( @{$output_files} ) {
        Bio::PanGenome::Exceptions::FileNotFound->throw( error => "Cant find blast results: " . $output_file )
          unless ( -e $output_file );
    }
    my $output_files_param = join( ' ', @{$output_files} );
    system( "cat $output_files_param > " . $self->blast_results_file_name );
    return 1;
}

sub _build__memory_required_in_mb
{
  my ($self) = @_;
  my $filename = $self->fasta_file;
  my $file_size = 1000;
  if(-e $filename)
  {
    $file_size = -s $filename;
    $file_size *=10;
    $file_size = int($file_size/1000000);
    $file_size = 100 if($file_size < 100);
  }

  return $file_size;
}

sub run {
    my ($self) = @_;
    my @expected_output_files;
    my @commands_to_run;
    for my $filename ( @{ $self->_sequence_file_names } ) {
        my ( $filename_without_directory, $directories, $suffix ) = fileparse($filename);
        my $output_seq_results_file =
          join( '/', ( $self->_working_directory_name, $filename_without_directory . '.out' ) );

        my $blast_database = Bio::PanGenome::External::Blastp->new(
            fasta_file     => $filename,
            blast_database => $self->_blast_database,
            exec           => $self->blastp_exec,
            output_file    => $output_seq_results_file,
        );
        push( @expected_output_files, $output_seq_results_file );
        push( @commands_to_run,       $blast_database->_command_to_run() );
    }
    my $job_runner_obj = $self->_job_runner_class->new( commands_to_run => \@commands_to_run, memory_in_mb => $self->_memory_required_in_mb, queue => $self->_queue );
    $job_runner_obj->run();
    $self->_combine_blast_results(\@expected_output_files);
    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

Bio::PanGenome::ParallelAllAgainstAllBlast - Run all against all blast in parallel

=head1 VERSION

version 1.133090

=head1 SYNOPSIS

Run blastp in parallel over a FASTA file of proteins
   use Bio::PanGenome::ParallelAllAgainstAllBlast;

   my $obj = Bio::PanGenome::ParallelAllAgainstAllBlast->new(
     fasta_file   => 'abc.fa',
   );
   $obj->run();

=head1 AUTHOR

Andrew J. Page <ap13@sanger.ac.uk>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Wellcome Trust Sanger Institute.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
