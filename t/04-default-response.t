#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::Dumper;

use ChatBot::Simple;

my $bot = ChatBot::Simple->new;

plan tests => 1;

pattern $bot 'hi' => 'hi!';

my $response = $bot->process_pattern('hi');

is($response, 'hi!');
