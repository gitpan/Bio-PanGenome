#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::CombinedProteome');
}

my $obj;

ok(
    $obj = Bio::PanGenome::CombinedProteome->new(
        proteome_files  => [ 't/data/example_1.faa', 't/data/example_2.faa' ],
        output_filename => 'combined_proteome.fa'
    ),
    'initalise object with two files'
);

ok( $obj->create_combined_proteome_file, 'Create a combined file' );

is(
    read_file('combined_proteome.fa'),
    read_file('t/data/expected_combined_proteome.fa'),
    'Combined file is as expected'
);
unlink('combined_proteome.fa');


throws_ok{
    Bio::PanGenome::CombinedProteome->new(
        proteome_files  => [ 't/data/example_1.faa', 't/data/non_existant_file.faa' ],
        output_filename => 'combined_proteome.fa')
    } qr /Cant open file/, 'non existant files should throw an error';


done_testing();
