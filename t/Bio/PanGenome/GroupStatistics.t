#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::GroupStatistics');
}

my $annotate_groups = Bio::PanGenome::AnnotateGroups->new(
  gff_files   => ['t/data/query_1.gff','t/data/query_2.gff','t/data/query_3.gff'],
  groups_filename => 't/data/query_groups',
);

my $analyse_groups = Bio::PanGenome::AnalyseGroups->new(
    fasta_files     => ['t/data/query_1.fa','t/data/query_2.fa','t/data/query_3.fa'],
    groups_filename => 't/data/query_groups'
);

my $obj;

ok($obj = Bio::PanGenome::GroupStatistics->new(
  annotate_groups_obj => $annotate_groups,
  analyse_groups_obj  => $analyse_groups 
),'Initialise group statistics object');
ok($obj->create_spreadsheet,'Create the CSV file');
ok(-e 'group_statitics.csv', 'CSV file exists');
is(read_file('group_statitics.csv'),read_file('t/data/expected_group_statitics.csv'), 'Spreadsheet content as expected');

unlink('group_statitics.csv');


############################

my $annotate_groups_2 = Bio::PanGenome::AnnotateGroups->new(
  gff_files   => ['t/data/query_1.gff','t/data/query_2.gff','t/data/query_3.gff','t/data/query_4_missing_genes.gff'],
  groups_filename => 't/data/query_groups_missing_genes',
);

my $analyse_groups_2 = Bio::PanGenome::AnalyseGroups->new(
    fasta_files     => ['t/data/query_1.fa','t/data/query_2.fa','t/data/query_3.fa','t/data/query_4_missing_genes.fa'],
    groups_filename => 't/data/query_groups_missing_genes'
);

ok($obj = Bio::PanGenome::GroupStatistics->new(
  annotate_groups_obj => $annotate_groups_2,
  analyse_groups_obj  => $analyse_groups_2 
),'Initialise group statistics object where one isolate has only 1 gene');
ok($obj->create_spreadsheet,'Create the CSV file');
ok(-e 'group_statitics.csv', 'CSV file exists');
is(read_file('group_statitics.csv'),read_file('t/data/expected_group_statitics_missing_genes.csv'), 'Spreadsheet content as expected with missing genes');

unlink('group_statitics.csv');



done_testing();
