package ChatBot::Simple;

use strict;
use warnings;
use Data::Dumper;
use Exporter qw( import );

use base qw( Class::Accessor );

our $VERSION = '0.01';
our @EXPORT = qw( context pattern transform process );

my $singleton;

__PACKAGE__->mk_ro_accessors(qw( patterns transforms ));

sub new {
    my ($class) = shift;
    return $class->SUPER::new({context => '', @_});
}

sub pattern {
    @_ = get_right_object(@_);
    my ($self, $pattern, @rest) = @_;

    my $code = ref $rest[0] eq 'CODE' ? shift @rest : undef;

    my $response = shift @rest;

    push @{ $self->{patterns}{$self->{context}} }, {
        pattern  => $pattern,
        response => $response,
        code     => $code,
    };

}

sub transform {
    @_ = get_right_object(@_);
    my ($self, @expr) = @_;

    my $transform_to = pop @expr;

    my $code = ref $expr[-1] eq 'CODE' ? pop @expr : undef;

    $self->{transforms}{$self->{context}} //= [];

    for my $exp (@expr) {
        push @{ $self->{transforms}{$self->{context}} },
          {
            pattern   => $exp,
            transform => $transform_to,
            code      => $code,
          };
    }
}

sub match {
    @_ = get_right_object(@_);
    my ( $self, $input, $pattern ) = @_;

    # regex match
    if ( ref $pattern eq 'Regexp' ) {
        if ( $input =~ $pattern ) {
            my @matches = ( $1, $2, $3, $4, $5, $6, $7, $8, $9 );
            my $i       = 0;
            my %result  = map { ':' . ++$i => $_ } grep { defined $_ } @matches;
            return \%result;
        }
        else {
            return;
        }
    }

    # text pattern (like "my name is :name")

    # first, extract the named variables
    my @named_vars = $pattern =~ m{(:\S+)}g;

    # transform named variables to '(\S+)'
    $pattern =~ s{:\S+}{'(.*)'}ge;

    # do the pattern matching
    if ( $input =~ m/\b$pattern\b/ ) {
        my @matches = ( $1, $2, $3, $4, $5, $6, $7, $8, $9 );
        my %result = map { $_ => shift @matches } @named_vars;

        # override memory with new information
        $self->{memory} = { %{ $self->{memory} //{} }, %result };

        return \%result;
    }

    return;
}

sub replace_vars {
    @_ = get_right_object(@_);

    my ( $self, $pattern, $named_vars ) = @_;

    my %vars = ( %{ $self->{memory} // {} }, %{$named_vars} );

    for my $var ( keys %vars ) {
        next if $var eq '';

        # escape regex characters
        my $quoted_var = $var;
        $quoted_var =~ s{([\.\*\+])}{\\$1}g;

        $pattern =~ s{$quoted_var}{$vars{$var}}g;
    }
    return $pattern;
}

sub process_transform {
    @_ = get_right_object(@_);
    my ($self, $str) = @_;

    for my $tr (@{ $self->{transforms}{$self->{context}} }) {
        next unless $self->match( $str, $tr->{pattern} );
        if ( ref $tr->{code} eq 'CODE' ) {
            warn "Transform code not implemented\n";
        }

        my $input = $tr->{pattern};
        my $vars = $self->match( $str, $input );

        if ($vars) {
            my $input = $self->replace_vars( $tr->{pattern}, $vars );
            $str =~ s/$input/$tr->{transform}/g;
            $str = $self->replace_vars( $str, $vars );
        }
    }

    # No transformations found...
    return $str;
}

sub process_pattern {
    @_ = get_right_object(@_);
    my ($self, $input) = @_;

    for my $pt (@{ $self->{patterns}{$self->{context}} }) {
        my $match = $self->match($input, $pt->{pattern});
        next if !$match;

        my $response;

        if ( $pt->{code} and ref $pt->{code} eq 'CODE' ) {
            $response = $pt->{code}( $input, $match );
        }

        $response //= $pt->{response};

        if ( ref $response eq 'ARRAY' ) {

            # deal with multiple responses
            $response = $response->[ rand( scalar(@$response) ) ];
        }

        my $response_interpolated = $self->replace_vars( $response, $match );

        return $response_interpolated;
    }

    warn "Couldn't find a match for '$input' (context = '$self->{context}')\n";
    warn Dumper $self->{patterns}{$self->{context}};

    return '';
}

sub process {
    @_ = get_right_object(@_);
    my ($self, $input) = @_;
    my $tr  = $self->process_transform($input);
    my $res = $self->process_pattern($tr);
    return $res;
}

sub get_right_object {
    # This checks @_. If the first parameter is a reference to an
    # object, we pass that along. If not, we use the singleton
    # object.
    my $maybe_me = $_[0];

    if (ref($maybe_me) eq __PACKAGE__) {
        return @_;
    }

    if (! defined $singleton) {
        $singleton = __PACKAGE__->new;
    }
    return($singleton, @_);
}

sub context {
    @_ = get_right_object(@_);

    my ($self, $ctx) = @_;
    if (defined $ctx) {
        $self->{context} = $ctx;
    }
    return $self->{context};
}

1;

__END__

=head1 NAME

ChatBot::Simple - new and flexible chatbot engine in Perl

=head1 SYNOPSIS

  use ChatBot::Simple;

  # simple pattern/response
  pattern 'hello' => 'hi!';
  pattern "what is your name?" => "my name is ChatBot::Simple";

  # simple transformations
  transform "what's" => "what is";

  # simple responses
  process("hello");
  process("what's your name?");

  # and much more!

=head1 DESCRIPTION

ChatBot::Simple is a new and flexible chatbot engine in Perl.

Instead of specifying the chatbot knowledge base in xml, we are
going to use the powerful text manipulation capabilities of Perl.

=head1 METHODS

You can either refer to these methods through an object:

    my $bot = ChatBot::Simple->new;
    $bot->process("hello");

Or directly in your namespace, like below. In this case it'll
automatically use a global object.

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
