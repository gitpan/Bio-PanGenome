#!perl

use Test::Most;
plan tests => 9;
bail_on_fail if 0;
use Env::Path 'PATH';

ok(scalar PATH->Whence($_), "$_ in PATH") for qw(blastp makeblastdb cd-hit mcl mcxdeblast fasta_grep bedtools fastatranslate muscle);

