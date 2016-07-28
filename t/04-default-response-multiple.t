#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::Dumper;

use ChatBot::Simple;

my $bot = ChatBot::Simple->new;

plan tests => 3;

pattern $bot 'hi' => [ 'hi!', 'hello!', 'howdy?' ];

srand(1);

{
  my $response = $bot->process_pattern('hi');
  is($response, 'hi!');
}

{
  my $response = $bot->process_pattern('hi');
  is($response, 'hello!');
}

{
  my $response = $bot->process_pattern('hi');
  is($response, 'howdy?');
}
