#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::ReorderSpreadsheet');
}

ok(
    my $obj = Bio::PanGenome::ReorderSpreadsheet->new(
        tree_file       => 't/data/reorder_isolates.tre',
        spreadsheet     => 't/data/reorder_isolates_input.csv',
        output_filename => 'reorder_isolates_output.csv'
    ),
    'initialise reordering the spreadsheet'
);

is_deeply($obj->_column_mappings,[0,1,2,3,4,5,6,8,9,7],'Column mappings with fixed in same order and end columns ordered by tree file');
ok( $obj->reorder_spreadsheet(), 'run the reorder method' );
ok( -e $obj->output_filename,    'check the output file exists' );



is(
    read_file('t/data/reorder_isolates_expected_output.csv'),
    read_file('reorder_isolates_output.csv'),
    'content of the spreadsheet as expected'
);

unlink('reorder_isolates_output.csv');

done_testing();
