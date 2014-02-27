use strict;
use warnings;

use ExtUtils::MakeMaker qw( WriteMakefile );

WriteMakefile(
   NAME          => 'DateTime::Format::RFC3339',
   AUTHOR        => 'Eric Brine <ikegami@adaelis.com>',
   VERSION_FROM  => 'lib/DateTime/Format/RFC3339.pm',
   ABSTRACT_FROM => 'lib/DateTime/Format/RFC3339.pm',
   LICENSE       => 'CC0_1_0',
   PREREQ_PM     => { 'DateTime'   => 0,
                      'Test::More' => 0,
                      'version'    => 0,
                    },
META_MERGE => { 'meta-spec' => { version => 2 },
                resources => { repository => {
                      type => 'git',
                      url  => 'https://github.com/ikegami/perl-DateTime-Format-RFC3339.git',
                      web  => 'https://github.com/ikegami/perl-DateTime-Format-RFC3339',
                  },
                },
              },
   dist          => { COMPRESS => 'gzip -9f', SUFFIX   => 'gz' },
   clean         => { FILES => 'DateTime-Format-RFC3339-*' },
);
