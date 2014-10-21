#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::AnnotateGroups');
}

my $obj;


ok($obj = Bio::PanGenome::AnnotateGroups->new(
  gff_files   => ['t/data/query_1.gff','t/data/query_2.gff','t/data/query_3.gff'],
  groups_filename => 't/data/query_groups',
),'initalise');

ok($obj->reannotate,'reannotate');

is(read_file('reannotated_groups_file'), read_file('t/data/expected_reannotated_groups_file'), 'groups reannotated as expected');

unlink('reannotated_groups_file');

done_testing();

