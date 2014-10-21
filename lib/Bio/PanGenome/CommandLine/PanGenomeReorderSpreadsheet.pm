package Bio::PanGenome::CommandLine::PanGenomeReorderSpreadsheet;

# ABSTRACT: Take in a tree and a spreadsheet and output a reordered spreadsheet


use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::PanGenome::ReorderSpreadsheet;

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'tree_file'            => ( is => 'rw', isa => 'Str' );
has 'spreadsheet_filename' => ( is => 'rw', isa => 'Str' );
has 'output_filename'      => ( is => 'rw', isa => 'Str', default => 'reordered_spreadsheet.csv' );
has 'tree_format'          => ( is => 'rw', isa => 'Str', default => 'newick' );

sub BUILD {
    my ($self) = @_;

    my ( $output_filename, $tree_file, $tree_format, $spreadsheet_filename, $help );

    GetOptionsFromArray(
        $self->args,
        'o|output_filename=s'      => \$output_filename,
        't|tree_file=s'            => \$tree_file,
        'f|tree_format=s'          => \$tree_format,
        's|spreadsheet_filename=s' => \$spreadsheet_filename,
        'h|help'                   => \$help,
    );

    $self->output_filename($output_filename)           if ( defined($output_filename) );
    $self->tree_file($tree_file)                       if ( defined($tree_file) );
    $self->tree_format($tree_format)                   if ( defined($tree_format) );
    $self->spreadsheet_filename($spreadsheet_filename) if ( defined($spreadsheet_filename) );

}

sub run {
    my ($self) = @_;

    ( defined($self->spreadsheet_filename) && defined($self->tree_file) && ( -e $self->spreadsheet_filename ) && ( -e $self->tree_file ) && ( !$self->help ) ) or die $self->usage_text;

    my $obj = Bio::PanGenome::ReorderSpreadsheet->new(
        tree_file       => $self->tree_file,
        spreadsheet     => $self->spreadsheet_filename,
        output_filename => $self->output_filename
    );
    $obj->reorder_spreadsheet();

}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
    Usage: pan_genome_reorder_spreadsheet [options]
    Take in a tree and a spreadsheet from the pan genome pipeline and output a spreadsheet with the columns ordered by the tree. 
    By default it expects the tree to be in newick format.
    
    # Reorder the spreadsheet columns to match the order of the samples in the tree
    pan_genome_reorder_spreadsheet -t my_tree.tre -s my_spreadsheet.csv
    
    # Specify an output filename
    pan_genome_reorder_spreadsheet -t my_tree.tre -s my_spreadsheet.csv -o output_spreadsheet.csv
    
    # This help message
    pan_genome_reorder_spreadsheet -h

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=pod

=head1 NAME

Bio::PanGenome::CommandLine::PanGenomeReorderSpreadsheet - Take in a tree and a spreadsheet and output a reordered spreadsheet

=head1 VERSION

version 1.133090

=head1 SYNOPSIS

Take in a tree and a spreadsheet and output a reordered spreadsheet

=head1 AUTHOR

Andrew J. Page <ap13@sanger.ac.uk>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Wellcome Trust Sanger Institute.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
