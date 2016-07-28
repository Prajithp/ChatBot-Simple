#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::Dumper;

use ChatBot::Simple;

my $bot = ChatBot::Simple->new;

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
    input => "my name is foo",
    expect => "I remember that",
  },
  {
    input => "what's my name?",
    expect => "your name is foo",
  },
  {
    input => "I'm called bar",
    expect => "I thought your name was foo",
  },
  {
    input => "what's my name?",
    expect => "your name is bar",
  },
);

# now we implement the rules above

my %mem;

$bot->transform("what's" => "what is");

$bot->transform("I'm" => "I am");

$bot->transform("I am called :name" => "my name is :name");

$bot->pattern("my name is :name" => sub {
  my ($str,$param) = @_;

  my $old_name = $mem{name};
  my $new_name = $mem{name} = $param->{':name'};

  if ($old_name) {
    return $old_name eq $new_name ? "I remember that" : "I thought your name was $old_name";
  }

  return;
} => "ok");

$bot->pattern("what is my name" => sub {
  my ($str,$param) = @_;
  return $mem{name} ? "your name is $mem{name}" : "I don't know";
});

plan tests => scalar @tests;

for my $test (@tests) {
  my $output = $bot->process($test->{input});
  is($output,$test->{expect},$test->{input} . " -> " . $test->{expect});
}
