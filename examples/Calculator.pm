package Calculator;

use ChatBot::Simple;

no warnings 'uninitialized';

my %var;

context '';

pattern qr{(\w+)\s*\=\s*(\d+)} => code => sub {
    my ( $input, $param ) = @_;
    $var{ $param->{':1'} } = $param->{':2'};
warn "Saved $param->{':1'} as $param->{':2'}";
    return;
}, response => 'ok';

pattern qr{(\d+|\w+)\s*([\+\-\*\/])\s*(\d+|\w+)} => sub {
    my ( $input, $param ) = @_;
    my ( $n1, $op, $n2 ) = ( $param->{':1'}, $param->{':2'}, $param->{':3'} );

    if ( exists $var{$n1} ) { $n1 = $var{$n1}; }
    if ( exists $var{$n2} ) { $n2 = $var{$n2}; }

    return
        $op eq '+' ? $n1 + $n2
      : $op eq '-' ? $n1 - $n2
      : $op eq '*' ? $n1 * $n2
      : $op eq '/' ? $n1 / $n2
      :              "I don't know how to calculate that!";
};

1;
