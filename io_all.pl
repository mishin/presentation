$number_of_lines = path("/tmp/foo.txt")->lines;

@files    =

print io->dir('.')->all;

perl -MIO::All -E "say io->dir('.')->all"
perl -MIO::All -E "@contents= io->dir('.')->all;print qq{$_ is a } . $_->type . qq{\n}    for @contents;"

perl -MIO::All -E "@contents= io->dir('.')->all;print qq{$_ is a } . $_->type . qq{\n}    for @contents;"

$contents = io->file('file.txt')->slurp;    # Read an entire file
@files    = io->dir('lib')->all; 

print "$_ is a " . $_->type . "\n"          # Each element of @contents
  for @contents;                            # is an IO::All object!!
  
  print "$_ is a " . $_->type . "\n"    for @contents;
  
  
 
# Stat functions:
printf "%s %s %s\n",                        # Print name, uid and size of
  $_->name, $_->uid, $_->size               # contents of current directory
    for io('.')->all; 

	# Stat functions:
printf "%s %s %s\n", $_->name, $_->uid, $_->size  for io('.')->all;  
perl -MIO::All -e "printf qq{%s %s %s\n}, $_->name, $_->length, $_->size  for sort    {$b->size <=> $a->size} io(q{.})->all; "

perl -MIO::All -e  "print qq{$_\n} for sort    {$b->size <=> $a->size}   io('.')->All_Files;"

perl -MIO::All -le "print for io(qq{.})->all"


perl -MIO::All -MIO::Dumper -e "io(q{./mydump})->dump(io(qq{.})->all);"


perl -MIO::All -e "printf qq{%s %s\n}, $_->name, $_->size for sort    {$b->size <=> $a->size} io(q{.})->all; "

perl -MIO::All -e "printf qq{%s %s\n}, $_->name, $_->size for sort    {$b->size <=> $a->size} grep { $_->name =~ /^perlre.*\.pod$/ } io(q(.))->all; "

perl -MDDP -MIO::All -e "printf qq{%s %s %s\n}, $_->name, $_->size, p $_ for sort    {$b->size <=> $a->size} grep { $_->name =~ /^perlre.*\.pod$/ } io(q(.))->all; "


my @found = grep { $_->name =~ /.+\/$file$/i } io(q(.))->all;

grep { $_->name =~ /.+\/$file$/i } io(q(.))->all;


perl -MIO::All -e "printf qq{%s %s\n},$_->name,$_->size for sort    {$b->size<=>$a->size}grep{$_->name=~/perlre.*\.pod/}io(q(.))->all"

perlretut.pod 120807
perlre.pod 106493
perlrecharclass.pod 44489
perlreguts.pod 40237
perlreapi.pod 30561
perlref.pod 29759
perlrebackslash.pod 26934
perlreftut.pod 19094
perlrequick.pod 18435
perlreref.pod 14923
