package Introduction;

use ChatBot::Simple;

no warnings 'uninitialized';

my %mem;

context '';

transform 'hello' => 'hi';

pattern 'hi' => sub {
    my ( $input, $param ) = @_;
    if ( context() ne 'name' ) {
        context 'name';
        return "hi! what's your name?";
    }
    return;
};

context 'name';

pattern "my name is :name" => sub {
    my ( $input, $param ) = @_;
    $mem{name} = $param->{':name'};

    context 'how_are_you';
    return "Hello, $mem{name}! How are you?";
};

transform 'goodbye', 'bye-bye', 'sayonara' => 'bye';

pattern 'bye' => 'bye!';

context 'how_are_you';

pattern 'fine' => 'great!';

pattern qr{^(\w+)$} => sub {
    my ( $input, $param ) = @_;
    if ( $bot->context eq 'name' ) {
        $mem{name} = $param->{':1'};
        context 'how_are_you';
        return "Hello, $mem{name}! How are you?";
    }
    return;
} => "I don't understand that!";

1;
