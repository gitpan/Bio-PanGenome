package Bio::PanGenome::External::Segmasker;

# ABSTRACT: Wrapper around Segmasker for low complexity filtering


use Moose;
with 'Bio::PanGenome::JobRunner::Role';

has 'fasta_file'        => ( is => 'ro', isa => 'Str', required => 1 );
has 'exec'              => ( is => 'ro', isa => 'Str', default  => 'segmasker' );
has 'output_file'       => ( is => 'ro', isa => 'Str', default  => 'database_masking.asnb' );
has '_infmt'            => ( is => 'ro', isa => 'Str', default  => 'fasta' );
has '_outfmt'           => ( is => 'ro', isa => 'Str', default  => 'maskinfo_asn1_bin' );

# Overload Role
has '_memory_required_in_mb'  => ( is => 'ro', isa => 'Int',  lazy => 1, builder => '_build__memory_required_in_mb' );

sub _build__memory_required_in_mb
{
  my ($self) = @_;
  my $filename = $self->fasta_file;
  my $memory_required = 1000;
  if(-e $filename)
  {
    $memory_required = -s $filename;
    # Convert to mb
    $memory_required = int($memory_required/1000000);
    # Triple memory for worst case senario
    $memory_required *= 3;
    $memory_required = 1000 if($memory_required < 1000);
  }

  return $memory_required;
}

sub _command_to_run {
    my ($self) = @_;
    return join(
        " ",
        (
            $self->exec,  
            '-in',           $self->fasta_file, 
            '-infmt',        $self->_infmt,
            '-parse_seqids', 
            '-outfmt',       $self->_outfmt,
            '-out',          $self->output_file
        )
    );
}

sub run {
  my ($self) = @_;
  my @commands_to_run;
  push(@commands_to_run, $self->_command_to_run );
  
  my $job_runner_obj = $self->_job_runner_class->new( commands_to_run => \@commands_to_run, memory_in_mb => $self->_memory_required_in_mb, queue => $self->_queue );
  $job_runner_obj->run();
  
  1;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=pod

=head1 NAME

Bio::PanGenome::External::Segmasker - Wrapper around Segmasker for low complexity filtering

=head1 VERSION

version 1.133090

=head1 SYNOPSIS

Wrapper around Segmasker for low complexity filtering

   use Bio::PanGenome::External::Segmasker;
   
   my $seg= Bio::PanGenome::External::Segmasker->new(
     fasta_file => 'contigs.fa',
   );
   
   $seg->run();

=head1 METHODS

=head2 output_file

Returns the path to the results file

=head1 AUTHOR

Andrew J. Page <ap13@sanger.ac.uk>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Wellcome Trust Sanger Institute.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
