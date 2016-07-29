package Introduction;

use ChatBot::Simple;

no warnings 'uninitialized';

{
    context '';

    pattern [ 'hi', 'hello' ]  => 
        response => "hi! what's your name?", 
        change_context => 'name';
}

{
    context 'name';

    transform [ "i'm :name", "call me :name" ] => 'my name is :name';

    pattern "my name is :name" => 
        response => "Hello, :name! How are you?",
        change_context => 'how_are_you';
}

{
    context 'how_are_you';

    pattern 'fine'            => "that's great, :name!";
    pattern ':something_else' => 'why do you say that?';
}

{
    context 'global';

    transform ['goodbye', 'bye-bye', 'sayonara'] => 'bye';
    pattern 'bye' =>
        response => 'bye!',
        set_flag => 'quit';
}

1;
