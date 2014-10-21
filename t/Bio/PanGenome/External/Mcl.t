#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Cwd;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::External::Mcl');
}

my $cwd = getcwd();
my $obj;

ok(
    $obj = Bio::PanGenome::External::Mcl->new(
        blast_results   => 'some_blast_results',
        mcxdeblast_exec => $cwd . '/t/bin/dummy_mcxdeblast',
        mcl_exec        => $cwd . '/t/bin/dummy_mcl',
        output_file     => 'output.groups'
    ),
    'initialise object with dummy values'
);

is(
    $obj->_command_to_run,
    $cwd
      . '/t/bin/dummy_mcxdeblast -m9 --score=r --line-mode=abc some_blast_results | '
      . $cwd
      . '/t/bin/dummy_mcl - --abc -I 1.5 -o output.groups 2> /dev/null',
    'Command constructed as expected'
);
ok( $obj->run(), 'run dummy command' );

unlink('output.groups');

ok(
    $obj = Bio::PanGenome::External::Mcl->new(
        blast_results => 't/data/blast_results',
    ),
    'initialise object with real values'
);
ok( $obj->run(), 'run the real command' );
is(read_file('output_groups'), read_file('t/data/expected_output_groups'), 'outgroups as expected');

unlink('output_groups');

1;

done_testing();
