#!/usr/bin/env perl
######################################
# $URL: http://mishin.narod.ru $
# $Date: Wed Oct 9 18:52:21 2011 $
# $Author: Jeremiah LaRocco, Nikolay Mishin (refactoring) $
# $Revision: 0.02 $
# $Source: gtrans.pl $
# $Description: Use translate.google.com to translate between languages. $
##############################################################################

use strict;
use warnings;

# use diagnostics;
use Modern::Perl;
use LWP::UserAgent;

use Getopt::Long;
use Pod::Usage;

use open ':locale';

our $VERSION = '0.02';
our $EMPTY   = q{};

my $man         = 0;
my $help        = 0;
my $from        = 'en';
my $to          = 'ru';
my $text        = 'yapc';
my $url_mashine = 'http://translate.google.com/translate_t?langpair=';

GetOptions(
    'help|?' => \$help,
    'man'    => \$man,
    'from=s' => \$from,
    'to=s'   => \$to,
    'text=s' => \$text,
) or pod2usage( -verbose => 2 );

if ($help) { pod2usage(1) }
if ($man) { pod2usage( -verbose => 2 ) }

my @translate_param = ( $from, $to, $text, $url_mashine );
main( \@translate_param );
exit;

sub main {
    my ($in_param) = @_;
    my @out;
    my $google_text = translate_text($in_param);
    push @out, $google_text;
    my $out = join $EMPTY, @out;
    say $out;
    return 1;
}

sub translate_text {
    my ($translate_param) = @_;
    my ( $src, $trg, $words, $url_translate ) = @{$translate_param};
    my $url = "${url_translate}${src}|${trg}&text=+${words}";
    my $ua  = LWP::UserAgent->new;
    $ua->agent($EMPTY);
    my $res = $ua->get($url);
    if ( $res->is_error ) { croak $res->status_line }
    my $html      = $res->decoded_content;
    my $start_rgx = q{onmouseout="this[.]style[.]backgroundColor='#fff'"\>};
    my $end_rgx   = q{\</span\>};
    my @matches = $html =~ m{$start_rgx(.*?)$end_rgx}gms;    #sxm;

    my $out = join $EMPTY, @matches;
    return $out;
}

__END__

=head1 NAME

gtrans.pl - Translate using  translate.google.com

=head1 SYNOPSIS

gtrans.pl --from en --to ru --text "This is a test"
gtrans.pl [options] [text to translate ...]

Options:
-help brief help message
-man full documentation
-from from language
-to to language
-text text to translate

=head1 USAGE

gtrans.pl --from en --to ru --text "This is a test"

=head1 REQUIRED ARGUMENTS

--text is requied argument, so you can invoke 

perl gtrans.pl --text "This is a test"

=head1 CONFIGURATION

no special configuration

=head1 DEPENDENCIES

Modern::Perl
LWP::UserAgent
Getopt::Long
Pod::Usage

=head1 OPTIONS

=over 2

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION

B<This program> will read the given input "text" and translate it to 
 selected language using translate.google.com.
 
=head1 DIAGNOSTICS


=head1 EXIT STATUS

unnown

=head1 INCOMPATIBILITIES

with winXP not work

=head1 BUGS AND LIMITATIONS

1. Windows - not ok
Cannot figure out an encoding to use at gtrans.pl line 20 
2. Ubuntu - ok
 
=head1 AUTHOR

Jeremiah LaRocco, Nikolay Mishin(mi@ya.ru) (refactoring)

=head1 LICENSE AND COPYRIGHT
 
Copyright 2013 by Nikolay Mishin M<lt>ishin@cpan.org<gt>.
 
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
 
See F<http://www.perl.com/perl/misc/Artistic.html>
 
=cut
=cut
