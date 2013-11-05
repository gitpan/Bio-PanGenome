package Bio::PanGenome::External::Muscle;

# ABSTRACT: Wrapper around Muscle for sequence alignment


use Moose;
with 'Bio::PanGenome::JobRunner::Role';

has 'fasta_files'   => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'exec'          => ( is => 'ro', isa => 'Str',      default  => 'muscle' );
has 'output_suffix' => ( is => 'ro', isa => 'Str',      default  => '.aln' );

# Overload Role
has '_memory_required_in_mb' => ( is => 'ro', isa => 'Int', lazy => 1, builder => '_build__memory_required_in_mb' );
has '_queue' => ( is => 'rw', isa => 'Str', default => 'small' );

sub _build__memory_required_in_mb {
    my ($self)          = @_;
    my $memory_required = 1000;
    return $memory_required;
}

sub _command_to_run {
    my ( $self, $fasta_file, $output_file ) = @_;
    return
      join( " ", ( $self->exec, '-in', $fasta_file, '-out', $output_file, '-quiet', '-maxhours', 7, ) );
}

sub run {
    my ($self) = @_;
    my @commands_to_run;

    for my $fasta_file ( @{ $self->fasta_files } ) {
        push( @commands_to_run, $self->_command_to_run( $fasta_file, $fasta_file.$self->output_suffix) );
    }

    my $job_runner_obj = $self->_job_runner_class->new(
        commands_to_run => \@commands_to_run,
        memory_in_mb    => $self->_memory_required_in_mb,
        queue           => $self->_queue,
        dont_wait       => $self->dont_wait,
    );
    $job_runner_obj->run();

    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=pod

=head1 NAME

Bio::PanGenome::External::Muscle - Wrapper around Muscle for sequence alignment

=head1 VERSION

version 1.133090

=head1 SYNOPSIS

Wrapper around Muscle for sequence alignment

   use Bio::PanGenome::External::Muscle;
   
   my $seg= Bio::PanGenome::External::Muscle->new(
     fasta_files => [],
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
