#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use File::Slurp;
use Cwd;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::CommandLine::TransferAnnotationToGroups');
}
my $script_name = 'Bio::PanGenome::CommandLine::TransferAnnotationToGroups';
my $cwd         = getcwd();

my %scripts_and_expected_files = (
    '-g t/data/query_groups t/data/query_1.gff t/data/query_2.gff t/data/query_3.gff' =>
      [ 'reannotated_groups', 't/data/expected_reannotated_groups_file' ],
);

mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

done_testing();
