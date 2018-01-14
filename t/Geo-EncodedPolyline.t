use strict;
use warnings;
use Path::Tiny;
use lib glob path (__FILE__)->parent->parent->child ('t_deps/modules/*/lib');
use Test::X1;
use Test::More;
use Geo::EncodedPolyline;

sub _s ($) {
  return join "\n", map {
    join "\t", map { 0+$_ } @$_;
  } @{$_[0]};
} # _s

test {
  my $c = shift;

  my $input = [
    [34.06694, -120.95],
    [34.06698, -126.453],
  ];
  my $output = Geo::EncodedPolyline->encode ($input, 1e5);

  is $output, 'ku|nEn`faVGvxq`@';

  my $restored = Geo::EncodedPolyline->decode ($output, 2, 1e5);
  is _s ($restored), _s ($input);

  done $c;
} n => 2;

test {
  my $c = shift;

  my $input = [
    [3],
    [1],
  ];
  my $output = Geo::EncodedPolyline->encode ($input, 1e0);

  is $output, 'EB';

  my $restored = Geo::EncodedPolyline->decode ($output, 1, 1e0);
  is _s ($restored), _s ($input);

  done $c;
} n => 2;

test {
  my $c = shift;

  my $input = [
    [4294967296, 3, 6],
    [4294967296 + 100, 1, 6],
  ];
  my $output = Geo::EncodedPolyline->encode ($input, 1);

  is $output, '______GEKgEB?';

  my $restored = Geo::EncodedPolyline->decode ($output, 3, 1);
  is _s ($restored), _s ($input);

  done $c;
} n => 2;

test {
  my $c = shift;

  my $input = [
    [38.5, -120.2], [40.7, -120.95], [43.252, -126.453],
  ];
  my $output = Geo::EncodedPolyline->encode ($input, 1e5);

  is $output, '_p~iF~ps|U_ulLnnqC_mqNvxq`@';

  my $restored = Geo::EncodedPolyline->decode ($output, 2, 1e5);
  is _s ($restored), _s ($input);

  done $c;
} n => 2;

test {
  my $c = shift;

  my $input = [
    [1], [4], [3],
  ];
  my $output = Geo::EncodedPolyline->encode ($input, 1e0);

  is $output, 'AE@';

  my $restored = Geo::EncodedPolyline->decode ($output, 1, 1e0);
  is _s ($restored), _s ($input);

  done $c;
} n => 2;

for (
  [-0.000001, '?'],
  [-179.9832104, '`~oia@'],
  [53.926935, 'krchI'],
  [53.92696, 'orchI'],
) {
  my ($input, $expected) = @$_;
  test {
    my $c = shift;
    my $x = Geo::EncodedPolyline->encode ([[$input]], 1e5);
    is $x, $expected;
    done $c;
  } n => 1;
}

for (
  [[[38.5, -120.2], [40.7, -120.95]], '_p~iF~ps|U_ulLnnqC'],
  [[
    [53.92694, 10.24444],
    [53.92696, 10.24645],
    [53.92713, 10.24852],
    [53.92746, 10.25056],
    [53.92806, 10.25324],
    [53.92851, 10.25511],
    [53.92922, 10.25800],
    [53.93009, 10.26135],
    [53.93083, 10.26395],
    [53.93167, 10.26630],
    [53.93273, 10.26926],
    [53.93321, 10.27112],
  ], 'krchIwzo}@CqKa@}KaAwKwBwOyAuJmCaQmD}SsCgOgDuMsEoQ_BsJ'],
) {
  my ($input, $expected) = @$_;
  test {
    my $c = shift;
    my $x = Geo::EncodedPolyline->encode ($input, 1e5);
    is $x, $expected;
    my $y = Geo::EncodedPolyline->decode ($x, 2, 1e5);
    is _s ($y), _s ($input);
    done $c;
  } n => 2;
}

test {
  my $c = shift;
  my $x = Geo::EncodedPolyline->decode ('', 2, 1e5);
  is _s ($x), _s ([]);
  done $c;
} n => 1, name => 'empty decode';

test {
  my $c = shift;
  my $x = Geo::EncodedPolyline->decode ("a\x{5000}", 2, 1e5);
  is _s ($x), _s ([]);
  done $c;
} n => 1, name => 'invalid decode';

test {
  my $c = shift;
  my $x = Geo::EncodedPolyline->decode ("\x{5000}", 2, 1e5);
  is _s ($x), _s ([]);
  done $c;
} n => 1, name => 'invalid decode';

test {
  my $c = shift;
  my $x = Geo::EncodedPolyline->decode ("?\x{5000}", 2, 1e5);
  is _s ($x), _s ([[0]]);
  done $c;
} n => 1, name => 'invalid decode';

test {
  my $c = shift;
  my $in = path (__FILE__)->parent->parent->child ('t_deps/data1.pl');
  my $out = path (__FILE__)->parent->parent->child ('t_deps/data1.ep');
  $in = do {
    no strict;
    eval $in->slurp;
  } or die $@;
  $out = $out->slurp;
  $out =~ s/\s+//g;

  my $encoded = Geo::EncodedPolyline->encode ($in, 1e5);
  is $encoded, $out;

  my $decoded = Geo::EncodedPolyline->decode ($encoded, 2, 1e5);
  my $reencoded = Geo::EncodedPolyline->encode ($decoded, 1e5);
  is $reencoded, $encoded;

  done $c;
} n => 2, name => 'larger data';

run_tests;

=head1 LICENSE

Copyright 2016-2018 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

Some tests are copied from
<http://cpansearch.perl.org/src/RRWO/Geo-Google-PolylineEncoder-0.06/t/>:

  Copyright (c) 2008-2010 Steve Purkis. Released under the same terms
  as Perl itself.

Thanks to jkondo and OND Inc. for providing test data.

=cut
