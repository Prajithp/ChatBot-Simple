#!/usr/bin/perl

use strict;
use warnings;

use ChatBot::Simple;

# the chatbot knowlege is stored in perl modules:
use Introduction;
use Calculator;

my $bot = ChatBot::Simple->new;

context $bot '';

Introduction->bot($bot);
Calculator->bot($bot);

print "> ";
while (my $input = <>) {
  chomp $input;

  my $response = $bot->process($input);

  print "$response\n\n" . $bot->context ."> ";
}
