#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::Dumper;

use ChatBot::Simple;

my $bot = ChatBot::Simple->new;

plan tests => 1;

$bot->pattern('my name is :first_name :last_name' => 'Hello, :first_name :last_name');

my $response = $bot->process_pattern('my name is Larry Wall');

is($response, 'Hello, Larry Wall');
