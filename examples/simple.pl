#!/usr/bin/perl

use strict;
use warnings;

use ChatBot::Simple;

# the chatbot knowlege is stored in perl modules:
use Introduction;
use Calculator;

# TODO: use Module::Pluggable to load knowledge automatically

my $bot = ChatBot::Simple->new;

Introduction->bot($bot);
Calculator->bot($bot);

print "> ";
while (my $input = <>) {
  chomp $input;

  my $response = $bot->process($input);

  print "$response\n\n> ";
}
