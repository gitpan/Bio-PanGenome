package Bio::PanGenome::JobRunner::Local;

# ABSTRACT: Execute a set of commands locally


use Moose;

has 'commands_to_run' => ( is => 'ro', isa => 'ArrayRef', required => 1 );

sub run {
    my ($self) = @_;

    for my $command_to_run ( @{ $self->commands_to_run } ) {
        system($command_to_run );
    }
    1;
}
no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

Bio::PanGenome::JobRunner::Local - Execute a set of commands locally

=head1 VERSION

version 1.133090

=head1 SYNOPSIS

 Execute a set of commands locally
   use Bio::PanGenome::JobRunner::Local;
   
   my $obj = Bio::PanGenome::JobRunner::Local->new(
     commands_to_run   => ['ls', 'echo "abc"'],
   );
   $obj->run();

=head1 AUTHOR

Andrew J. Page <ap13@sanger.ac.uk>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Wellcome Trust Sanger Institute.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
