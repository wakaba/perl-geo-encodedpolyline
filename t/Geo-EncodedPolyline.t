use strict;
use warnings;
use Path::Tiny;
use lib glob path (__FILE__)->parent->parent->child ('t_deps/modules/*/lib');
use Test::X1;
use Test::More;
use Geo::EncodedPolyline;
use Data::Dumper;
$Data::Dumper::Useqq = 1;

test {
  my $c = shift;

  my $input = [
    [34.06694, -120.95],
    [34.06698, -126.453],
  ];
  my $output = Geo::EncodedPolyline->encode ($input, 1e5);

  is $output, 'ku|nEn`faVGvxq`@';

  my $restored = Geo::EncodedPolyline->decode ($output, 2, 1e5);
  is Dumper ($restored), Dumper ($input);

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
  is Dumper ($restored), Dumper ($input);

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
  is Dumper ($restored), Dumper ($input);

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
  is Dumper ($restored), Dumper ($input);

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
  is Dumper ($restored), Dumper ($input);

  done $c;
} n => 2;

run_tests;

=head1 LICENSE

Copyright 2016 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
