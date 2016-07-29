#!/usr/bin/perl

use strict;
use warnings;

use ChatBot::Simple;

# the chatbot knowlege is stored in perl modules:
use Introduction;
use Calculator;

context '';

print context . "> ";
while ( my $input = <> ) {
    chomp $input;

    my $response = process $input;

    print "$response\n\n";
    exit if ( %{ flags() }{quit} );
    print "> ";
}
