#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::Dumper;

use ChatBot::Simple;

my $bot = ChatBot::Simple->new;

plan tests => 3;

my $count = 0;
$bot->pattern('count' => sub {
  return ++$count;
});

for my $i (1..3) {
  my $response = $bot->process_pattern('count');
  is($response, $i);
}
