use Modern::Perl;
use charnames ':full';
binmode( STDOUT, ":utf8" );
use WWW::Mechanize::Firefox;
use URI::Split qw( uri_split uri_join );
use Try::Tiny;
use Getopt::Long;
use DDP;
my %args;
GetOptions(\%args,
           "word=s"
) or die "Invalid arguments!";
die "Missing -word!" unless $args{word};
 
 my $url = 'https://translate.google.ru/?hl=ru&tab=wT#en/ru/'.$args{word};
my $mech = WWW::Mechanize::Firefox->new( tab => 'current', );

$mech->get($url);
sleep 10;
$mech->selector('span.hps');
sleep 3;
# p $mech;
print $_->{href}, " - ", $_->{innerHTML}, "\n"
        for $mech->selector('span.hps');
# $mech->highlight_node(
       # $mech->selector('span'));
	   #result_box
# $mech->highlight_node(
      # $mech->selector('SPAN#result_box.short_text'));
# my @para = $mech->xpath('//p');span id="result_box"

# $mech->selector('span.hps');
# # $mech->selector('span[id=result_box]');
# p $mech;
# print $_->{href}, " - ", $_->{innerHTML}, "\n"
       # for $mech->selector('span[id=result_box]');
# p $mech;
# <span class="hps">близко</span>
# <a title="View More Information on FOO" href="tranlist.phtml?scode=FOO&sname=&refpg=1&snapcode=&ssector=1123&scheme=default" name="tranlist">

# Collects all paragraphs
	  
    <>;	   
	   
# $mech->selector('class')
# my $stop = 2;
# backup_url_from_page( $url, $stop );
 
sub backup_url_from_page {
my ( $url, $stop ) = @_;
my $mech = WWW::Mechanize::Firefox->new( tab => 'current', );
$mech->get($url);
sleep 4;
 
my $collection = collect_all_links_tag($mech);
 
while ( my ( $file_name, $url ) = each( %{$collection} ) ) {
try {
$mech->get($url);
$mech->save_content( $file_name, $file_name . 'files' );
say "url $url successfully saved in $file_name";
}
catch {
warn "caught error: $_ url \n $url not saved in file $file_name";
};
last if --$stop == 0;
}
 
}
 
sub collect_all_links_tag {
my $mech = shift;
my %collection;
 
for ( $mech->selector('a') ) {
my $name = $_->{innerHTML};
my $href = $_->{href};
my ( $scheme, $auth, $path, $query, $frag ) = uri_split($href);
$path =~ s{/}{_}g;
if ( $path !~ /.*[.](htm|html)$/i ) {
$path = $path . ".html";
}
$collection{$path} = $href;
}
return ( \%collection );
}