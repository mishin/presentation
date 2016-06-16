#ошибка во 2-й строке: @lines ничего не присваивается, да и при die хотелось бы выводить адекватное сообщение, ну еще по PBP файл хендлер должен быть переменной, а не символической ссылкой.
#после perltidy -b 01_count_word.pl получается так
#!/usr/bin/env perl
open my $fh, $ARGV[0] || die "Usage: $0 file_4_word_count\n errno:$!";
my @lines = <$fh>;
my @words = map { split /\s/ } @lines;
printf "%8d %8d\n", scalar(@lines), scalar(@words);
close $fh;
