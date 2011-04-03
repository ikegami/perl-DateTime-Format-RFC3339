#!perl -T

use strict;
use warnings;

use DateTime                  qw( );
use DateTime::Format::RFC3339 qw( );

my @tests;
BEGIN {
   @tests = (
      [
         DateTime->new( year => 2002, month => 7, day => 1, hour => 13, minute => 50, second => 5, time_zone => 'UTC' ),
         '2002-07-01T13:50:05Z',
      ],
      [
         DateTime->new( year => 2002, month => 7, day => 1, hour => 13, minute => 50, second => 5, time_zone => 'Europe/London' ),
         '2002-07-01T13:50:05+01:00',
      ],
      [
         DateTime->new( year => 2002, month => 1, day => 1, hour => 13, minute => 50, second => 5, time_zone => 'Europe/London' ),
         '2002-01-01T13:50:05+00:00',
      ],
      [
         DateTime->new( year => 2002, month => 1, day => 1, hour => 13, minute => 50, second => 5, time_zone => 'America/New_York' ),
         '2002-01-01T13:50:05-05:00',
      ],
   );
}

use Test::More tests => 0+@tests;

for (@tests) {
   my ($dt, $expected_str) = @$_;
   $dt->set_formatter('DateTime::Format::RFC3339');
   my $actual_str = "$dt";
   is( $actual_str, $expected_str );
}
