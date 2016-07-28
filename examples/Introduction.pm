package Introduction;

use ChatBot::Simple;

no warnings 'uninitialized';

my %mem;
my $bot;

sub bot {
    my $class = shift;
    $bot = shift;
    load_bot();
}

sub load_bot {
    context $bot '';

    transform $bot 'hello' => 'hi';

    pattern $bot 'hi' => sub {
      my ($input, $param) = @_;
      if ($bot->context ne 'name') {
        context $bot 'name';
        return "hi! what's your name?";
      }
      return;
    };

    context $bot 'name';

    pattern $bot "my name is :name" => sub {
      my ($input,$param) = @_;
      $mem{name} = $param->{':name'};
      context $bot 'how_are_you';
      return "Hello, :name! How are you?";
    };

    transform $bot 'goodbye', 'bye-bye', 'sayonara' => 'bye';

    pattern $bot 'bye' => 'bye!';

    context $bot 'how_are_you';

    pattern $bot 'fine' => 'great!';

    pattern $bot qr{^(\w+)$} => sub {
      my ($input,$param) = @_;
      if ($bot->context eq 'name') {
        $mem{name} = $param->{':1'};
        context $bot 'how_are_you';
        return "Hello, $mem{name}! How are you?";
      }
      return;
    } => "I don't understand that!";

}

1;
