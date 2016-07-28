#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::Dumper;

use ChatBot::Simple;

my $bot = ChatBot::Simple->new;

plan tests => 1;

$bot->pattern('my name is :name' => sub {
} => 'Hello, :name');

my $response = $bot->process_pattern('my name is larry');

is($response, 'Hello, larry');
