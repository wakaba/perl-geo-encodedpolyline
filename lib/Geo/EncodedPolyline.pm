package Geo::EncodedPolyline;
use strict;
use warnings;
our $VERSION = '1.0';
use POSIX qw(floor);

sub _encode ($$) {
  my $v = floor (($_[0] * $_[1]) + 0.5);
  my $negative = $v < 0;
  if ($negative) {
    $v = (~(-$v)) + 1;
    $v <<= 1;
    $v = ~$v;
  } else {
    $v <<= 1;
  }
  my @r;
  while ($v) {
    my $x = $v & 0b11111;
    $v >>= 5;
    $x |= 0x20 if $v;
    push @r, pack 'C', $x + 63;
  }
  return pack 'C', 0 + 63 unless @r;
  return @r;
} # _encode

sub encode ($$$) {
  my $points = $_[1];
  my $f = $_[2];

  return '' unless @$points;

  my $n = 0+@{$points->[0]};
  return '' unless $n;

  my @r;
  my $current = [map { 0 } 1..$n];

  for my $pt (@$points) {
    for (0..($n-1)) {
      push @r, _encode ($pt->[$_] - $current->[$_], $f);
      $current->[$_] = $pt->[$_];
    }
  }

  return join '', @r;
} # encode

sub decode ($$$$) {
  my $n = $_[2];
  my $f = $_[3];
  my @current = map { 0 } 1..$n;
  my @r;
  my $i = 0;
  while ($_[1] =~ /\G([\x5F-\x7E]*[\x3F-\x5E])/g) {
    my $v = 0;
    for (reverse split //, $1) {
      $v <<= 5;
      $v |= ((ord $_) - 63) & 0b11111;
    }
    if ($v & 1) {
      $v >>= 1;
      $v = -~(~$v-1);
    } else {
      $v >>= 1;
    }
    my $j = $i % $n;
    $v = ($current[$j] += $v);

    if ($j) {
      $r[-1]->[$j] = $v / $f;
    } else {
      push @r, [$v / $f];
    }
    $i++;
  }
  return \@r;
} # decode

1;

=head1 LICENSE

Copyright 2016 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
