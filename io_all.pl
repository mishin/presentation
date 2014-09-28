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

@lines = map { $_ = $line++ . qq( $_) } io( $found[0] )->slurp;

perl -MIO::All -e "printf qq{%s %s\n}, $_->name, $_->size for sort    {$b->size <=> $a->size} grep { $_->name =~ /^perlre.*\.pod$/ } io(q(.))->all; "

perl -MIO::All -e "printf qq{%s %s\n}, $_->name, $_->size for sort    {$b->size <=> $a->size} grep {/perlre.*pod/} io(q(.))->all; "

perl -MIO::All -e "printf qq{%s %s\n}, $_->name, $_->size for sort    {$b->size <=> $a->size} grep {/perlre.*pod/} io('.')->all; "

io->file('file.txt')->slurp; 

perl -MIO::All -e "printf qq{%s %s\n}, $_->name, $_->size for sort    {$b->size <=> $a->size} grep {/perlre.*pod/} io('.')->all; "

sort    {$b->size <=> $a->size}

use IO::All;                                # Let the madness begin...
 
# Some of the many ways to read a whole file into a scalar
io('file.txt') > $contents;                 # Overloaded "arrow"
$contents < io 'file.txt';                  # Flipped but same operation
$io = io 'file.txt';                        # Create a new IO::All object
$contents = $$io;                           # Overloaded scalar dereference
$contents = $io->all;                       # A method to read everything
$contents = $io->slurp;                     # Another method for that
$contents = join '', $io->getlines;         # Join the separate lines
$contents = join '', map "$_\n", @$io;      # Same. Overloaded array deref
$io->tie;                                   # Tie the object as a handle
$contents = join '', <$io>;                 # And use it in builtins
# and the list goes on ...
 
# Other file operations:
@lines = io('file.txt')->slurp;             # List context slurp
$content > io('file.txt');                  # Print to a file
io('file.txt')->print($content, $more);     # (ditto)
qq{%s %s %s\n}, $_->name, $_->size,$_->slurp for

perl -MIO::All -e "for (grep {/perlrebackslash.pod/} io('.')->all){printf qq{%s %s %s\n}, $_->name, $_->size,$->getlines }"

perl -MIO::All -E "for my $f(grep {/perlrebackslash.pod/} io('.')->all){say $f->name.' '.$f->size.' '.map { $_ = $line++} $f->slurp}"


perl -MIO::All -E "say $_->name.' '.map { $_ = $line++} $_->slurp for (grep {/perlre.*[.]pod/} io('.')->all)"

perl -MIO::All -e "printf qq{%s %s\n}, $_->name, $_->size for sort    {$b->size <=> $a->size} grep {/perlre.*pod/} io('.')->all; "

perl -MIO::All -E "for my $f(grep {/perlre.*[.]pod/} io('.')->all){push @pods, $f->name.' '.map { $_ = $line++} $f->slurp};say join( qq{\n},@pods)"




perl -MIO::All -E "push @pods,$_->name.' '.map { $_ = $line++} $_->slurp for (grep {/perlre.*[.]pod/} io('.')->all);say join( qq{\n}, map  { $_->[0] } sort { $a->[1] <=> $b->[1] } map  { [$_, m/(\d+)$/] } @pods)"

perl -MIO::All -E "push @pods,$_->name.' '.map { $_ = $line++} $_->slurp for (grep {/perlre.*[.]pod/} io('.')->all);say join( qq{\n},@pods)"




@sorted = map  { $_->[0] } sort { $a->[1] <=> $b->[1] } map  { [$_, m/(\d+)$/] } @unsorted;



@sorted = map  { $_->[0],sort { $a->[1] cmp $b->[1] } map  { m/\s+(\d+)/}}@pods;say @sorted"


my @sorted = map  { $_->[0],sort { $a->[1] cmp $b->[1] } map  { m/\s+(\d+)/}@pods;

    my @quickly_sorted_files =
    map { $_->[0] }
    sort { $a->[1] <=> $b->[1] }
    map { [$_, -s $_] }
    @files;


perl -MIO::All -e "printf qq{%s %s\n}, $_->name,map { $_ = $line++} $_->slurp for (grep {/perlre.*[.]pod/} io('.')->all)"



perl -MIO::All -e "printf qq{%s %s\n}, $_->name, $_->size for sort    {$b->size <=> $a->size} grep {/perlre.*pod/} io('.')->all; "


my @sorted = map  { $_->[0],
             sort { $a->[1] cmp $b->[1] }
             map  { map { $_ = $line++} $_->slurp;
                    [ $_, pack "l>l>", $1 || 0, -s $_ ] }
             grep {/perlre.*pod/} io('.')->all;

# sort file names by the (first) sequence of digits, then by size
my @sorted = map  { $_->[0],
             sort { $a->[1] cmp $b->[1] }
             map  { m/(\d+)/; # sort by digits in file name
                    [ $_, pack "l>l>", $1 || 0, -s $_ ] }
             @filelist;

my @sorted_length = sort { length($a) <=> length($b) } @files;
map { $_ = $line++} $f->slurp

perl -MIO::All -e "printf qq{%s %s %s\n}, $_->name, $_->size for sort    {$b->size <=> $a->size} grep {/perlre.*pod/} io('.')->all; "


perl -MIO::All -E "for my $f(grep {/perlre.*pod/} io('.')->all){say $f->name.' '.$f->size.' '.map { $_ = $line++} $f->slurp}"

perl -MIO::All -E "for my $f(grep {/perlre.*pod/} io('.')->all){say $f->name.' '.map { $_ = $line++} $f->slurp}"

sort {$a->name cmp $b->name}
    grep {! /CVS|\.svn/} io("$t/mydir")->all_files(0) 

perl -MIO::All -e "for my $f(grep {/perlre.*pod/} io('.')->all){printf qq{%s %s\n}, $f->name,{map { $_ = $line++} $f->slurp}}"

perl -MIO::All -e "for (grep {/perlrebackslash.pod/} io('.')->all){printf qq{%s %s %s\n}, $_->name, $_->size,map { $_ = $line++} $_->slurp }"


printf qq{%s %s %s\n}, $_->name, $_->size,$->getlines 

$contents = join '', $io->getlines;         # Join the separate lines
$contents = join '', map "$_\n", @$io;      # Same. Overloaded array deref


perl -MIO::All -e "printf qq{%s %s %s\n}, $_->name, $_->size,$_->slurp for  grep {/perlre.*pod/} io('.')->all; "

perl -MIO::All -e "sort map $_->filename,io()->dir($t, q{.})->glob(q{perlre*pod});"

is(join('+', map $_->filename, grep {! /CVS|\.svn/} $io5->all), 'dir1+dir2+file1+file2+file3');

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


perl -MIO::All -E "push @pods,($_->name.' '.map { $_ = $line++} $_->slurp for (grep {/perlre.*[.]pod/} io('.')->all));say join( qq{\n}, map  { $_->[0] } sort { $a->[1] <=> $b->[1] } map  { [$_, m/(\d+)$/] } @pods)"


perl -MIO::All -E "push @p,$_->name.' '.map{$_= $l++}$_->slurp for(grep{/perlre/}io('.')->all);say join(qq{\n},map{$_->[0]}sort{$a->[1]<=>$b->[1]}map{[$_,m/(\d+)$/]}@p)"

perl -MIO::All -E "
say join qq{\n},
map{$_->[0]}sort{$a->[1]<=>$b->[1]}map{[$_,map{$_= $l++}$_->slurp]}
for(grep{/perlre/}io('.')->all)"



perl -MIO::All -E "say join qq{\n},map{$_->[0]}sort{$a->[1]<=>$b->[1]}map{[$_,map{$_= $l++}$_->slurp]}(grep{/perlre/}io('.')->all)"


;say join(qq{\n},map{$_->[0]}sort{$a->[1]<=>$b->[1]}map{[$_,m/(\d+)$/]}@p)"

"push @p,$_->name.' '.map{$_= $l++}$_->slurp 


perl -MIO::All -E "say $_->name.' '.map{$_= $l++}$_->slurp for(grep{/perlre/}io('.')->all)" | perl -e "print sort {length $a <=> length $b}  <>"

perl -MIO::All -E"say $_->name.' '.map{$_= $l++}$_->slurp for(grep{/perlre/}io('.')->all)"|perl -E "say sort{length $a<=>length $b}<>"

    perl -e 'print sort {length $a <=> length $b} <>' textFile

One-Liner: Print second column, unless it contains a number

    perl -lane 'print $F[1] unless $F[1] =~ m/[0-9]/' wordCounts.txt



perl -MIO::All -E "say join qq{\n},map{$_->[0]}sort{$a->[1]<=>$b->[1]}map{[$_,map{$l++}$_->slurp]}(grep{/perlre/}io('.')->all)"
	
	
perl -MIO::All -E "push @p,$_->name.' '.map{$l++}$_->slurp for(grep{/perlre/}io('.')->all);say join qq{\n},map{$_->[0]}sort{$a->[1]<=>$b->[1]}map{[$_,m/(\d+)$/]}@p"

perl -MIO::All -E "for(grep{/perlre/}io('.')->all){push @p,$_->name.' '.map{$l++}$_->slurp};say join qq{\n},map{$_->[0]}sort{$a->[1]<=>$b->[1]}map{[$_,/\d+/]}@p"
11)
perl -MIO::All -E "for(grep{/perlre/}io('.')->all){push @p,$_->name.' '.map{$l++}$_->slurp};say join qq{\n},map{$_->[0]}sort{$a->[1]<=>$b->[1]}map{[$_,/\d+/]}@p"
12)

perl -MIO::All -MData::Dumper -E "for(grep{/perlre/}io('.')->all){$p{$_->name}=map{$l++}$_->slurp};print Dumper(\%p);"

perl -MIO::All  -MData::Dumper -E "$p{$_->name}=map{$l++}$_->slurp for grep{/perlre/}io('.')->all;say Dumper(\%p)"

perl -MIO::All -E "$p{$_->name}=map{$l++}$_->slurp for grep{/perlre/}io('.')->all;say qq{$key $p{$key}} for$key(sort{$p{$a}<=>$p{$b}}keys%p)"

c:\Users\TOSH\Documents\GitHub\perldoc-ru\pod2-ru\target\pods>


perl -MIO::All -E "$p{$_->name}=map{$l++}$_->slurp for grep{/perlre/}io('.')->all;for$k(sort{$p{$a}<=>$p{$b}}keys%p){say qq{$k $p{$k}}}"

perl -MIO::All -E "$p{$_->name}=map{$l++}$_->slurp for grep{/perlre/}io('.')->all;for $k(sort {$p{$a}<=>$p{$b}} keys %p){say qq{$k $p{$k}}}"

perl -MIO::All -E "$p{$_->name}=map{$l++}$_->slurp for grep{/^perl.*[.]pod$/}io('.')->all;for $k(sort {$p{$a}<=>$p{$b}} keys %p){say qq{$k $p{$k}}}" > pod_size.lst

perlreref.pod 408
perlrequick.pod 519
perlreftut.pod 526
perlrebackslash.pod 664
perlref.pod 754
perlreapi.pod 826
perlreguts.pod 928
perlrecharclass.pod 1081
perlre.pod 2562
perlretut.pod 2928
perlreref.pod 408

perl -MIO::All -E "$p{$_->name}=map{$l++}$_->slurp for grep{/perlre/}io('.')->all;say qq{$key $p{$key}} for $key ( sort { $p{$a} <=> $p{$b} } keys %p )"

  my @keys = sort { $hash{$a} <=> $hash{$b} } keys %hash;


perl -MIO::All  -M"Hash::MoreUtils qw/hashsort/"-E "$p{$_->name}=map{$l++}$_->slurp for grep{/perlre/}io('.')->all;@p_s=hashsort(\%p);say qq{@p_s}"

for $key ( sort keys %p ){say qq{$key $p{$key}}}"

 my @keys = sort { $hash{$a} <=> $hash{$b} } keys %hash;

perl -MIO::All -MData::Dumper -E "$p{$_->name}=map{$l++}$_->slurp} for(grep{/perlre/}io('.')->all);print Dumper(\%p)"

perl -MIO::All -MHash::MoreUtils -E "for(grep{/perlre/}io('.')->all){$p{$_->name}=map{$l++}$_->slurp};say hashsort sub { {$a <=> $b} },\%p"

say hashsort sub { {$a <=> $b} },\%p;

perl -MIO::All -E "for(grep{/perlre/}io('.')->all){$n_s{$_->name}=map{$l++}$_->slurp};for $name (sort {$a <=> $b} values %n_s) {say $name,$n_s{$name}}"

perl -MIO::All -E "for(grep{/perlre/}io('.')->all){$n_s{$_->name}=map{$l++}$_->slurp};for $name (sort {$a <=> $b} keys %n_s) { printf "%s %s\n",$name, $n_s{$name}}"

    for $name (sort {$a <=> $b} keys %n_s) { printf "%-8s %s\n",$name, $n_s{$name};    }


    for $name (sort values %n_s) {say $name,$n_s{$name}}

use Data::Dumper;
my %hash = ('abc' => 123, 'def' => [4,5,6]);
print Dumper(\%hash);

say join qq{\n},map{$_->[0]}sort{$a->[1]<=>$b->[1]}map{[$_,/\d+/]}@p"


perl -MIO::All -E "for(grep{/perlre/}io('.')->all){push @p,$_};say join qq{\n},map{$_->[0]}sort{$a->[1]<=>$b->[1]}map{[$_,map{$l++}$_->slurp]}@p"

say join qq{\n},map{$_->[0]}sort{$a->[1]<=>$b->[1]}map{[$_,map{$l++}$_->slurp]}"

,$_->name.' '.map{$l++}$_->slurp};say join qq{\n},map{$_->[0]}sort{$a->[1]<=>$b->[1]}map{[$_,/\d+/]}@p"


perl -MIO::All -E "say map{$_->[0]}sort{$a->[1]<=>$b->[1]}map{[$_,map{$l++}$_->slurp]}grep{/perlre/}io('.')->all"

$_->name.' '.map{$l++}$_->slurp for
	