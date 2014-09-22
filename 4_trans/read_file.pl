use Modern::Perl;
use File::Slurp;     
my $filename='c:\\TCPU59\\scripts\\temp_file';
my $text=read_file( $filename );
# open my $fh, "<:utf8", $filename;
# open my $fh, "<:utf8", $filename;
# while (my $line = <$fh>) {
# say $line;
# }
# open my $fh,"<>:utf8","/some/path" or die $!;
# print $fh $string;
# close $fh or die $!;
use Encode;
Encode::from_to($text, 'utf-8', 'windows-1251');
say $text;