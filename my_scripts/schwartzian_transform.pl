#!/usr/bin/perl
use Benchmark;

@unsorted = (
    "Larry Wall",
    "Jane Sally Doe",
    "John Doe",
    "Morphius",
    "Jane Alice Doe",
    "Arthur C. Clarke"
);

print "\@unsorted: @unsorted";

timethese(
    100000,
    {
        "schwartzian" => sub {
            my @sorted =
              map  { $_->[0] }
              sort { $a->[1] cmp $b->[1] }
              map  { m/(.*?)\s*(\S+)$/; [ $_, "$2 $1" ] } @unsorted;

            # print "1. schwartzian \@sorted: @sorted";
        },
        "schwartzian_foreach" => sub {
            foreach $_ (@unsorted) {
                $result_for{$_} = expensive_func($_);
            }
            my @output = sort { $result_for{$a} cmp $result_for{$b} } @unsorted;

            # print "2. schwartzian_foreach \@output: @output";
            # my @sorted =
            # map  { $_->[0] }
            # sort { $a->[1] cmp $b->[1] }
            # map  { m/(.*?)\s*(\S+)$/; [ $_, "$2 $1" ] } @unsorted;
        },
        "sort routine" => sub {
            my @sorted = sort mysort @unsorted;

            # print "3. sort routine \@sorted: @sorted";
        }
    }
);

my @sorted =
  map  { $_->[0] }
  sort { $a->[1] cmp $b->[1] }
  map  { m/(.*?)\s*(\S+)$/; [ $_, "$2 $1" ] } @unsorted;
print "1. schwartzian \@sorted: @sorted\n";

my %result_for;
foreach $_ (@unsorted) {
    $result_for{$_} = expensive_func($_);
}

# use Data::Dumper;
# print Dumper( \%result_for );
my @output = sort { $result_for{$a} cmp $result_for{$b} } @unsorted;
print "2. schwartzian_foreach \@output: @output\n";

my @sorted = sort mysort @unsorted;
print "3. sort routine \@sorted: @sorted\n";

sub expensive_func {
    # my ($a)=shift;
    # $a =~ /(.*?)\s*(\S+)$/;
    /(.*?)\s*(\S+)$/;
    # my   $aa = "$2 $1";
    return "$2 $1";    #$aa;
}

sub mysort {
    $a =~ m/(.*?)\s*(\S+)$/;
    $aa = "$2 $1";
    $b =~ m/(.*?)\s*(\S+)$/;
    $bb = "$2 $1";
    return $aa cmp $bb;
}
