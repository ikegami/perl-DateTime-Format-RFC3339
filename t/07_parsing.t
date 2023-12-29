#!perl

use strict;
use warnings;

use Test::More;

use DateTime                  qw( );
use DateTime::Format::RFC3339 qw( );

my @tests = (
   [
      '2002-07-01T13:50:05Z',
      DateTime->new( year => 2002, month => 7, day => 1, hour => 13, minute => 50, second => 5, time_zone => 'UTC' ),
   ],
   [
      '2002-07-01T13:50:05.123Z',
      DateTime->new( year => 2002, month => 7, day => 1, hour => 13, minute => 50, second => 5, nanosecond => 123000000, time_zone => 'UTC' ),
   ],
);

plan tests => 0+@tests;

for ( @tests ) {
   my ( $str, $expected_dt ) = @$_;

   my $actual_dt = eval { DateTime::Format::RFC3339->parse_datetime( $str ) };
   my $e = $@;

   if ( ref( $expected_dt ) eq 'DateTime' ) {
      is( $actual_dt, $expected_dt, $str );
      diag( "Exception: $e" ) if $e;
   } else {
      like( $e, $expected_dt, "$str - Throws exception" )
   }
}
