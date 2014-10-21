#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;
use Cwd;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::ParallelAllAgainstAllBlast');
}
my $obj;
my $cwd = getcwd();

ok($obj = Bio::PanGenome::ParallelAllAgainstAllBlast->new(
  fasta_file       => 't/data/example_1.faa',
  blastp_exec      => $cwd.'/t/bin/dummy_blastp',
  makeblastdb_exec => $cwd.'/t/bin/dummy_makeblastdb',
),'initialise obj with mocked external applications');
ok($obj->run(),'Run locally');
ok(-e $obj->_working_directory_name.'/blast_results', 'Combined blast results');

unlink('output_contigs.phr');
unlink('output_contigs.pin');
unlink('output_contigs.psq');
unlink('results.out');

done_testing();
