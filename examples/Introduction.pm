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
    transform $bot 'hello' => 'hi';

    pattern $bot 'hi' => sub {
      my ($input, $param) = @_;
      if (!$mem{name}) {
        $mem{topic} = 'name';
        return "hi! what's your name?";
      }
      return;
    };

    pattern $bot "my name is :name" => sub {
      my ($input,$param) = @_;
      $mem{name} = $param->{':name'};
      $mem{topic} = 'how_are_you';
      return "Hello, :name! How are you?";
    };

    transform $bot 'goodbye', 'bye-bye', 'sayonara' => 'bye';

    pattern $bot 'bye' => 'bye!';

    pattern $bot 'fine' => 'great!';

    pattern $bot qr{^(\w+)$} => sub {
      my ($input,$param) = @_;
      if ($mem{topic} eq 'name') {
        $mem{name} = $param->{':1'};
        $mem{topic} = 'how_are_you';
        return "Hello, $mem{name}! How are you?";
      }
      return;
    } => "I don't understand that!";

}

1;
