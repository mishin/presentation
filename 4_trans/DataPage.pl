use Data::Page;
use Modern::Perl;

#my $page             = Data::Page->new();
my $total_entries    = 1500;
my $entries_per_page = 900;
my $current_page     = 1;

my @array=1..$total_entries;
#say "@array";
my $page = Data::Page->new( $total_entries, $entries_per_page, $current_page );
my $i;
for ( $i = 1 ; $i <= $page->last_page ; $i++ ) {
    say $i;
$page->current_page($i);
my @curr=@array[$page->first-1 .. $page->last-1];            
say "@curr";
} 