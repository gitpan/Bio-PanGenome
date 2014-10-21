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
    use_ok('Bio::PanGenome::CommandLine::ParallelAllAgainstAllBlastp');
}
my $script_name = 'Bio::PanGenome::CommandLine::ParallelAllAgainstAllBlastp';
my $cwd = getcwd();


my %scripts_and_expected_files = (
    '-m '.$cwd.'/t/bin/dummy_makeblastdb -b '.$cwd.'/t/bin/dummy_blastp -j Local t/data/example_1.faa' =>
      [ 'blast_results', 't/data/empty_file' ],
   '-o different_output_filename -m '.$cwd.'/t/bin/dummy_makeblastdb -b '.$cwd.'/t/bin/dummy_blastp -j Local t/data/example_1.faa' =>
      [ 'different_output_filename', 't/data/empty_file'  ],
);

mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

done_testing();