#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::Dumper;

use ChatBot::Simple;

my @tests = (
  {
    input => "what's my name?",
    expect => "I don't know",
  },
  {
    input => "my name is foo",
    expect => "ok",
  },
  {
    input => "what's my name?",
    expect => "your name is foo",
  },
  {
    input => "my name is bar",
    expect => "I thought your name was foo",
  },
  {
    input => "what's my name?",
    expect => "your name is bar",
  },
);

# now we implement the rules above

my %mem;

transform "what's" => "what is";

pattern "my name is :name" => sub {
  my ($str,$param) = @_;

  my $old_name = $mem{name};
  my $new_name = $mem{name} = $param->{':name'};

  if ($old_name) {
    return $old_name eq $new_name ? "I know it" : "I thought your name was $old_name";
  }

  return;
} => "ok";

pattern "what is my name" => sub {
  my ($str,$param) = @_;
  return $mem{name} ? "your name is $mem{name}" : "I don't know";
} => "x";

plan tests => scalar @tests;

for my $test (@tests) {
  my $output = ChatBot::Simple::process($test->{input});
  is($output,$test->{expect},$test->{input} . " -> " . $test->{expect});
}
