my @states = slurp("states").split("\n\n");
my $WORD = lines("words").roll;
my %letters_found;

while @states {
    loop {
        my @guessed_word;
        for $WORD.comb {
            if %letters_found{$_} {
                push @guessed_word, $_.uc;
            }
            else {
                push @guessed_word, "_";
            }
        }

        say "Word: ", join " ", @guessed_word;

        if none(@guessed_word) eq "_" {
            say "Congratulations! You guessed it right!";
            exit;
        }

        say "";
        my $letter = prompt "Guess a letter: ";

        my $correct_guess = any($WORD.comb).lc eq $letter.lc;
        if $correct_guess {
            %letters_found{$letter} = True;
        }
        else {
            say shift @states;
            last;
        }
    }
}

say "Aww, you ran out of guesses.";
say "The correct word was '$WORD'";
