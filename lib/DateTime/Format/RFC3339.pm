
package DateTime::Format::RFC3339;

use strict;
use warnings;

use version; our $VERSION = qv( 'v1.11.0' );

use Carp     qw( croak );
use DateTime qw( );


use constant FIRST_IDX    => 0;
use constant IDX_FORMAT   => FIRST_IDX + 0;
use constant IDX_DECIMALS => FIRST_IDX + 1;
use constant IDX_SEP      => FIRST_IDX + 2;
use constant IDX_SEP_RE   => FIRST_IDX + 3;
use constant IDX_UC_ONLY  => FIRST_IDX + 4;
use constant NEXT_IDX     => FIRST_IDX + 5;


my $default_self;


sub new {
   my $class = shift;
   my %opts  = @_;

   my $decimals = delete( $opts{ decimals } );
   my $sep      = delete( $opts{ sep      } );
   my $sep_re   = delete( $opts{ sep_re   } );
   my $uc_only  = delete( $opts{ uc_only  } );

   $sep    //= "T";
   $sep_re //= quotemeta( $sep );
   $uc_only = $uc_only ? 1 : 0;

   my $self = bless( [], $class );

   #$self->[ IDX_FORMAT   ] = undef;
   $self->[  IDX_DECIMALS ] = $decimals;
   $self->[  IDX_SEP      ] = $sep;
   $self->[  IDX_SEP_RE   ] = $sep_re;
   $self->[  IDX_UC_ONLY  ] = $uc_only;

   return $self;
}


sub parse_datetime {
   my $self = shift;
   my $str  = shift;

   $self = $default_self //= $self->new()
      if !ref( $self );

   $str = uc( $str )
      if !$self->[ IDX_UC_ONLY ];

   my ( $Y, $M, $D ) = $str =~ s/^([0-9]{4})-([0-9]{2})-([0-9]{2})// ? ( 0+$1, 0+$2, 0+$3 ) : ()
       or croak( "Incorrectly formatted date" );

   $str =~ s/^$self->[ IDX_SEP_RE ]//
      or croak( "Incorrectly formatted datetime" );

   my ( $h, $m, $s ) = $str =~ s/^([0-9]{2}):([0-9]{2}):([0-9]{2})// ? ( 0+$1, 0+$2, 0+$3 ) : ()
       or croak( "Incorrectly formatted time" );

   my $ns = $str =~ s/^\.([0-9]{1,9})[0-9]*// ? 0+substr( $1.( '0' x 8 ), 0, 9 ) : 0;

   my $tz;
   if    ( $str =~ s/^Z//                           ) { $tz = 'UTC';    }
   elsif ( $str =~ s/^([+-])([0-9]{2}):([0-9]{2})// ) { $tz = "$1$2$3"; }
   else                                               { croak( "Incorrect or missing time zone offset" ); }

   $str =~ /^\z/
      or croak( "Incorrectly formatted datetime" );

   return DateTime->new(
      year       => $Y,
      month      => $M,
      day        => $D,
      hour       => $h,
      minute     => $m,
      second     => $s,
      nanosecond => $ns,
      time_zone  => $tz,
      formatter  => $self,
   );
}


sub format_datetime {
   my $self = shift;
   my $dt   = shift;

   $self = $default_self //= $self->new()
      if !ref( $self );

   my $format = $self->[ IDX_FORMAT ];
   if ( !$format ) {
      my $decimals = $self->[ IDX_DECIMALS ];
      my $sep      = $self->[ IDX_SEP      ];

      $sep = "%%" if $sep eq "%";

      if ( defined( $decimals ) ) {
         if ( $decimals ) {
            $self->[ IDX_FORMAT ] = $format = "%Y-%m-%d${sep}%H:%M:%S.%${decimals}N";
         } else {
            $self->[ IDX_FORMAT ] = $format = "%Y-%m-%d${sep}%H:%M:%S";
         }
      } else {
         if ( $dt->nanosecond() ) {
            $format = "%Y-%m-%d${sep}%H:%M:%S.%9N";
         } else {
            $format = "%Y-%m-%d${sep}%H:%M:%S";
         }
      }
   }

   my $tz;
   if ( $dt->time_zone()->is_utc() ) {
      $tz = 'Z';
   } else {
      my $secs  = $dt->offset();

      # TODO Maybe we could cache this.
      # There are only so many offests, and most
      # programs probably only uses one or two.
      my $sign  = $secs < 0 ? '-' : '+';  $secs = abs( $secs );
      my $mins  = int( $secs / 60 );      $secs %= 60;
      my $hours = int( $mins / 60 );      $mins %= 60;
      if ( $secs ) {
         ( $dt = $dt->clone() )
            ->set_time_zone( 'UTC' );
         $tz = 'Z';
      } else {
         $tz = sprintf( '%s%02d:%02d', $sign, $hours, $mins );
      }
   }

   return $dt->strftime( $format ) . $tz;
}


1;


__END__

=head1 NAME

DateTime::Format::RFC3339 - Parse and format RFC3339 datetime strings


=head1 VERSION

Version 1.11.0


=head1 SYNOPSIS

   use DateTime::Format::RFC3339;

   my $format = DateTime::Format::RFC3339->new();
   my $dt = $format->parse_datetime( '2002-07-01T13:50:05Z' );

   # 2002-07-01T13:50:05Z
   say $format->format_datetime( $dt );


=head1 DESCRIPTION

This module understands the RFC3339 date/time format, an ISO 8601 profile,
defined at L<http://tools.ietf.org/html/rfc3339>.

It can be used to parse these formats in order to create the appropriate
objects.


=head1 CONSTRUCTOR

=head2 new

   my $format = DateTime::Format::RFC3339->new();
   my $format = DateTime::Format::RFC3339->new( %options );

A number of options are supported:

=over

=item * decimals

   decimals => undef      [default]
   decimals => $decimals

Date-time strings generated by <format_datetime> will have
this many decimals (an integer from zero to nine). If C<undef>,
zero will be used if the date-time has no decimals, nine otherwise.

=item * sep

   sep => "T"      [default]
   sep => $sep

=item * sep_re

   sep_re => $sep_re

The spec allows for a separator other than "C<T>"
to be used between the date and the time.

The string provided to the C<sep> option is used
when formatting date-time objects into strings, and
the regex pattern provided to the C<sep_re> option
is used when parsing strings into date-time objects.

The default for C<sep_re> is a regex pattern that
matches the separator (which is "C<T>" by default).

=item * uc_only

   uc_only => 0   [default]
   uc_only => 1

Only an uppercase date and time separator and an uppercase timezone offset "Z"
will be accepted by C<parse_datetime> when this option is true.

=back


=head1 METHODS

=head2 parse_datetime

   my $dt = DateTime::Format::RFC3339->parse_datetime( $string );
   my $dt = $format->parse_datetime( $string );

Given a RFC3339 datetime string, this method will return a new
L<DateTime> object.

If given an improperly formatted string, this method will croak.

For a more flexible parser, see L<DateTime::Format::ISO8601>.


=head2 format_datetime

   my $string = DateTime::Format::RFC3339->format_datetime( $dt );
   my $string = $format->format_datetime( $dt );

Given a L<DateTime> object, this methods returns a RFC3339 datetime
string.


=head1 SEE ALSO

=over 4

=item * L<DateTime>

=item * L<DateTime::Format::ISO8601>

=item * L<http://tools.ietf.org/html/rfc3339>, "Date and Time on the Internet: Timestamps"

=back


=head1 DOCUMENTATION AND SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc DateTime::Format::RFC3339

You can also find it online at this location:

=over

=item * L<https://metacpan.org/dist/Datetime-Format-RFC3339>

=back

If you need help, the following are great resources:

=over

=item * L<https://stackoverflow.com/|StackOverflow>

=item * L<http://www.perlmonks.org/|PerlMonks>

=item * You may also contact the author directly.

=back


=head1 BUGS

Please report any bugs or feature requests using L<https://github.com/ikegami/perl-Datetime-Format-RFC3339/issues>.
I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.


=head1 REPOSITORY

=over

=item * Web: L<https://github.com/ikegami/perl-Datetime-Format-RFC3339>

=item * git: L<https://github.com/ikegami/perl-Datetime-Format-RFC3339.git>

=back


=head1 AUTHOR

Eric Brine, C<< <ikegami@adaelis.com> >>


=head1 COPYRIGHT AND LICENSE

No rights reserved.

The author has dedicated the work to the Commons by waiving all of his
or her rights to the work worldwide under copyright law and all related or
neighboring legal rights he or she had in the work, to the extent allowable by
law.

Works under CC0 do not require attribution. When citing the work, you should
not imply endorsement by the author.


=cut
