#!perl

use strict;
use warnings;

use DateTime                  qw( );
use DateTime::Format::RFC3339 qw( );

use Test::More;

my $default_formatter = 'DateTime::Format::RFC3339';

my @tests;

push @tests, (
   [
      'UTC',
      DateTime->new( year => 2002, month => 7, day => 1, hour => 13, minute => 50, second => 5, time_zone => 'UTC' ),
      $default_formatter,
      '2002-07-01T13:50:05Z',
   ],
   [
      'Positive offset',
      DateTime->new( year => 2002, month => 7, day => 1, hour => 13, minute => 50, second => 5, time_zone => 'Europe/London' ),
      $default_formatter,
      '2002-07-01T13:50:05+01:00',
   ],
   [
      'Zero offset',
      DateTime->new( year => 2002, month => 1, day => 1, hour => 13, minute => 50, second => 5, time_zone => 'Europe/London' ),
      $default_formatter,
      '2002-01-01T13:50:05+00:00',
   ],
   [
      'Negative offset',
      DateTime->new( year => 2002, month => 1, day => 1, hour => 13, minute => 50, second => 5, time_zone => 'America/New_York' ),
      $default_formatter,
      '2002-01-01T13:50:05-05:00',
   ],
   [
      'Offset with non-integral minutes',
      DateTime->new( year => 1880, month => 1, day => 1, hour => 0, minute => 0, second => 0, time_zone => 'America/New_York' ),
      $default_formatter,
      '1880-01-01T04:56:02Z',
   ],
);

{
   my $dt = DateTime->new( year => 2023, month => 12, day => 31, hour => 23, minute => 59, second => 59, time_zone => 'UTC' );

   {
      my $formatter = DateTime::Format::RFC3339->new( decimals => undef );
      push @tests, (
         [
            'decimals => undef - No nanoseconds',
            $dt->clone()->set_nanosecond( 0 ),
            $formatter,
            '2023-12-31T23:59:59Z',
         ],
         [
            'decimals => undef - With nanoseconds',
            $dt->clone()->set_nanosecond( 123_000 ),
            $formatter,
            '2023-12-31T23:59:59.000123000Z',
         ],
      );
   }

   for my $decimals ( 0 .. 9 ) {
      my $formatter = DateTime::Format::RFC3339->new( decimals => $decimals );

      push @tests, (
         [
            "decimals => $decimals",
            $dt->clone()->set_nanosecond( 987_654_321 ),
            $formatter,
            ( $decimals
            ? sprintf( '2023-12-31T23:59:59.%sZ', substr( '987654321', 0, $decimals ) )
            : '2023-12-31T23:59:59Z'
            ),
         ],
      );
   }
}

plan tests => 0+@tests;

for ( @tests ) {
   my ( $name, $dt, $formatter, $expected_str ) = @$_;
   $dt->set_formatter( $formatter );
   my $actual_str = "$dt";
   is( $actual_str, $expected_str, $name );
}
