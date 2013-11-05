
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Create a pan genome",
  "AUTHOR" => "Andrew J. Page <ap13\@sanger.ac.uk>",
  "BUILD_REQUIRES" => {
    "Data::Dumper" => 0,
    "Env::Path" => 0,
    "File::Slurp" => 0,
    "Test::Most" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Bio-PanGenome",
  "EXE_FILES" => [
    "bin/create_pan_genome",
    "bin/create_pan_genome_plots.R",
    "bin/extract_proteome_from_gff",
    "bin/pan_genome_post_analysis",
    "bin/pan_genome_reorder_spreadsheet",
    "bin/parallel_all_against_all_blastp",
    "bin/plot_pan_genome_groups",
    "bin/query_pan_genome",
    "bin/transfer_annotation_to_groups"
  ],
  "LICENSE" => "gpl",
  "NAME" => "Bio::PanGenome",
  "PREREQ_PM" => {
    "Bio::PanGenome::Output::NumberConservedGroups" => 0,
    "Bio::PanGenome::Output::NumberNewGroups" => 0,
    "Bio::PanGenome::Output::NumberTotalGroups" => 0,
    "Bio::PanGenome::Output::NumberUniqueGroups" => 0,
    "Bio::SeqIO" => 0,
    "Bio::Tools::GFF" => 0,
    "Bio::TreeIO" => 0,
    "Chart::Clicker" => 0,
    "Chart::Clicker::Context" => 0,
    "Chart::Clicker::Data::DataSet" => 0,
    "Chart::Clicker::Data::Marker" => 0,
    "Chart::Clicker::Data::Series" => 0,
    "Chart::Clicker::Renderer::Bar" => 0,
    "Cwd" => 0,
    "Exception::Class" => 0,
    "File::Basename" => 0,
    "File::Copy" => 0,
    "File::Find::Rule" => 0,
    "File::Path" => 0,
    "File::Temp" => 0,
    "Geometry::Primitive::Rectangle" => 0,
    "Getopt::Long" => 0,
    "Graphics::Color::RGB" => 0,
    "LSF" => 0,
    "LSF::JobManager" => 0,
    "List::Util" => 0,
    "Moose" => 0,
    "Moose::Role" => 0,
    "POSIX" => 0,
    "Text::CSV" => 0
  },
  "VERSION" => "1.133090",
  "test" => {
    "TESTS" => "t/*.t t/Bio/PanGenome/*.t t/Bio/PanGenome/CommandLine/*.t t/Bio/PanGenome/External/*.t t/Bio/PanGenome/Output/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



