package ChatBot::Simple;

use strict;
use warnings;

use base qw( Class::Accessor );

our $VERSION = '0.01';

__PACKAGE__->mk_ro_accessors(qw( patterns transforms ));

sub pattern {
  my ($self, $pattern, @rest) = @_;

  my $code = ref $rest[0] eq 'CODE' ? shift @rest : undef;

  my $response = shift @rest;

  push @{ $self->{patterns} }, {
    pattern  => $pattern,
    response => $response,
    code     => $code,
  };
}

sub transform {
  my ($self, @expr) = @_;

  my $transform_to = pop @expr;

  my $code = ref $expr[-1] eq 'CODE' ? pop @expr : undef;

  for my $exp (@expr) {
    push @{ $self->{transforms} }, {
      pattern   => $exp,
      transform => $transform_to,
      code      => $code,
    };
  }
}

sub match {
  my ($input, $pattern) = @_;

  # regex match
  if (ref $pattern eq 'Regexp') {
    if ($input =~ $pattern) {
      my @matches = ($1,$2,$3,$4,$5,$6,$7,$8,$9);
      my $i = 0;
      my %result = map { ':' . ++$i => $_ } grep { defined $_ } @matches;
      return \%result;
    } else {
      return;
    }
  }

  # text pattern (like "my name is :name")

  # first, extract the named variables
  my @named_vars = $pattern =~ m{(:\S+)}g;

  # transform named variables to '(\S+)'
  $pattern =~ s{:\S+}{'(.*)'}ge;

  # do the pattern matching
  if ($input =~ m/$pattern/) {
    my @matches = ($1,$2,$3,$4,$5,$6,$7,$8,$9);
    my %result = map { $_ => shift @matches } @named_vars;
    return \%result;
  }

  return;
}

sub replace_vars {
  my ($pattern, $named_vars) = @_;
  for my $var (keys %$named_vars) {
    next if $var eq '';

    # escape regex characters
    my $quoted_var = $var;
    $quoted_var =~ s{([\.\*\+])}{\\$1}g;

    $pattern =~ s{$quoted_var}{$named_vars->{$var}}g;
  }
  return $pattern;
}

sub process_transform {
  my ($self, $str) = @_;

  for my $tr (@{ $self->{transforms} }) {
    next unless match($str, $tr->{pattern});
    if (ref $tr->{code} eq 'CODE') {
      warn "Transform code not implemented\n";
    }
    #warn sprintf("Replace '%s' with '%s' in '%s'\n", $tr->{input}, $tr->{output}, $str);
    my $input = $tr->{pattern};
    my $vars = match($str,$input);
    if ($vars) {
      my $input = replace_vars($tr->{pattern},$vars);
      $str =~ s/$input/$tr->{transform}/g;
      $str = replace_vars($str,$vars);
    }
  }

  # No transformations found...
  return $str;
}

sub process_pattern {
  my ($self, $input) = @_;

  for my $pt (@{ $self->{patterns} }) {
    my $match = match($input, $pt->{pattern});
    next if !$match;

    my $response;

    if ($pt->{code} and ref $pt->{code} eq 'CODE') {
      $response = $pt->{code}($input,$match);
    }

    $response //= $pt->{response};

    if (ref $response eq 'ARRAY') {
      # deal with multiple responses
      $response = $response->[ rand(scalar(@$response)) ];
    }

    my $response_interpolated = replace_vars($response, $match);

    return $response_interpolated;
  }

  warn "Couldn't find a match for '$input'";
  return;
}

sub process {
  my ($self, $input) = @_;
  my $tr  = $self->process_transform($input);
  my $res = $self->process_pattern($tr);
  return $res;
}

1;

__END__

=head1 NAME

ChatBot::Simple - new and flexible chatbot engine in Perl

=head1 SYNOPSIS

  use ChatBot::Simple;

  my $bot = ChatBot::Simple->new;

  # simple pattern/response
  pattern $bot 'hello' => 'hi!';
  pattern $bot "what is your name?" => "my name is ChatBot::Simple";

  # simple transformations
  transform $bot "what's" => "what is";

  # simple responses
  $bot->process("hello");
  $bot->process("what's your name?");

  # and much more!

=head1 DESCRIPTION

ChatBot::Simple is a new and flexible chatbot engine in Perl.

Instead of specifying the chatbot knowledge base in xml, we are
going to use the powerful text manipulation capabilities of Perl.

=head1 METHODS

Indirect notation, for example

  pattern $bot 'hello' => 'hi!';

is used here where it seems to make more sense. It's possible to use
normal notation just fine:

  $bot->pattern 'hello' => 'hi!';

=head2 pattern

pattern is used to register response patterns:

  pattern $bot 'hello' => 'hi!';

=head2 transform

transform is used to register text normalizations:

  transform $bot "what's" => "what is";

Like C<pattern>, you can use named variables and code:

  transform $bot "I am called :name" => "my name is :name";

  transform $bot "foo" => sub {
    # ...
  } => "bar";

Differently from C<pattern>, you can specify multiple transformations
at once:

  transform $bot "goodbye", "byebye", "hasta la vista", "sayonara" => "bye";

=head2 process

process will read a sentence, apply all the possible transforms and
patterns, and return a response.

=head1 FEATURES

=head2 Multiple (random) responses:

  pattern $bot 'hello' => [ 'hi!', 'hello!', 'what\'s up?' ];

=head2 Named variables

  pattern $bot "my name is :name" => "hello, :name!";

=head2 Code execution

  my %mem;

  pattern $bot "my name is :name" => sub {
    my ($input,$param) = @_;
    $mem{name} = $param->{name};
  } => "nice to meet you, :name!";

=head2 Regular expressions

  pattern $bot qr{what is (\d+) ([+-/*]) (\d+)} => sub {
    my ($input,$param) = @_;
    my ($n1,$op,$n2) = ($param->{1}, $param->{2}, $param->{3});
    # ...
    return $result;
  };

(See more examples in the C<t/> directory)

=head1 METHODS

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2013 Nelson Ferraz

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.
