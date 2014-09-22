#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;
use Carp;
use FindBin;
use YAML::Tiny;
use English qw(-no_match_vars);
use IPC::Open3 'open3';

#use Smart::Comments;

my $start_time = time;
main();
my $elapsed_time = wdhms( time - $start_time );
my $ret          = print "Time elapsed: $elapsed_time\n";

sub main {

    my $conf = YAML::Tiny::LoadFile( $FindBin::Bin . '/config.yml' )
      or croak "Couldn't open YAML::Tiny->errstr: $OS_ERROR";

    my $email           = $conf->{neospeech}->{email};
    my $accountId       = $conf->{neospeech}->{accountId};
    my $loginPassword   = $conf->{neospeech}->{loginPassword};
    my $text            = 'Some DOS and dont for travellers';
    my $ref_source_data = import_sql_and_data();
    my $input           = $ref_source_data->{'input.txt'};
### $input
    my @arry_from_txt = split /\n/, $input;
    my $i = 0;
    for my $msg (@arry_from_txt) {
        if ( $msg !~ m/\./sm ) { $msg .= '.' }
        say $msg;
        $i++;
        say $i;
        get_voice( $email, $accountId, $loginPassword, $msg );
    }

    #get_voice( $email, $accountId, $loginPassword, $text );

}

sub get_voice {
    my ( $email, $accountId, $loginPassword, $text ) = @_;

    #my $text = 'test';
    my $run = 'curl https://tts.neospeech.com/rest_1_1.php ';
    $run .= '-d method=ConvertSimple ';
    $run .= "-d 'email=$email' ";
    $run .= "-d accountId=$accountId ";
    $run .= "-d loginKey=LoginKey ";
    $run .= "-d loginPassword=$loginPassword ";
    $run .= "-d voice=TTS_JULIE_DB ";
    $run .= "-d outputFormat=FORMAT_WAV ";
    $run .= "-d sampleRate=8 ";
    $run .= "-d text='$text' ";

    say $run;
    my ( $resp_1, $rez, $resp_2, $rez2, $dnl_url, $resp_3 ) = ('');

    $resp_1 = run_shell($run);
    $rez = join( '', @{$resp_1} );

#$rez =
#'# % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current# Dload  Upload   Total   Spent    Left  Speed# 289   101  100   101    0   191     56    106  0:00:01  0:00:01 --:--:--   121# <response resultCode="0" resultString="success" conversionNumber="3" status="Queued" statusCode="1"/>';
    my $RGX_CONV_NUMBER = qr/conversionNumber="(\d+)"/smo;
    my $conv_number     = '';
    if ( $rez =~ m/$RGX_CONV_NUMBER/sm ) {
        $conv_number = $1;
        say "\$conv_number=$conv_number";

        my $run2 = 'curl https://tts.neospeech.com/rest_1_1.php ';
        $run2 .= '-d method=GetConversionStatus ';
        $run2 .= "-d conversionNumber=$conv_number ";
        $run2 .= '-d method=GetConversionStatus ';
        $run2 .= "-d 'email=$email' ";
        $run2 .= "-d accountId=$accountId ";
        $run2 .= "-d loginKey=LoginKey ";
        $run2 .= "-d loginPassword=$loginPassword ";

        say $run2;

        $resp_2 = run_shell($run2);
        $rez2 = join( '', @{$resp_2} );

#$rez2 =
#'<response resultCode="0" resultString="success" status="Completed" statusCode="4"#  downloadUrl="https://tts.neospeech.com/audio/a.php/XXXXXXX/XXXXXXX/result_3.wav"/>';
        my $RGX_DNL_URL = qr/downloadUrl="([^"]+)"/smo;
        my $conv_number = '';
        if ( $rez2 =~ m/$RGX_DNL_URL/sm ) {
            $dnl_url = $1;
            say "\$dnl_url=$dnl_url";

            my $run3 = 'curl -O ' . $dnl_url;

            say $run3;
            $resp_3 = run_shell($run3);
        }

        #“$1″ if /.*downloadUrl=”([^"]+)”.*/’

        # curl https://tts.neospeech.com/rest_1_1.php \
        # -d method=GetConversionStatus \
        # -d conversionNumber=3 \
        # -d 'email=me@example.com' \
        # -d accountId=ef******* \
        # -d loginKey=LoginKey \
        # -d loginPassword=5**************6
    }
}

#надо будет добавить для обработки
#|perl -nle ‘print “$1″ if /.*conversionNumber=”(\d+)”.*/’
#|perl -nle ‘print “$1″ if /.*downloadUrl=”([^"]+)”.*/’
# % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
# Dload  Upload   Total   Spent    Left  Speed
# 289   101  100   101    0   191     56    106  0:00:01  0:00:01 --:--:--   121
# <response resultCode="0" resultString="success" conversionNumber="3" status="Queued" statusCode="1"/>

sub run_shell {
    my ($cmd) = @_;
    my @args  = ();
    my $EMPTY = q{};
    my $ret   = undef;
    my ( $HIS_IN, $HIS_OUT, $HIS_ERR ) = ( $EMPTY, $EMPTY, $EMPTY );
    my $childpid = open3( $HIS_IN, $HIS_OUT, $HIS_ERR, $cmd, @args );
    $ret = print {$HIS_IN} "stuff\n";
    close $HIS_IN or croak "unable to close: $HIS_IN $ERRNO";
    ;    # Give end of file to kid.
    my @outlines = '';

    if ($HIS_OUT) {
        @outlines = <$HIS_OUT>;                       # Read till EOF.
        $ret = print " STDOUT:\n", @outlines, "\n";
    }
    if ($HIS_ERR) {
        my @errlines = <$HIS_ERR>;    # XXX: block potential if massive
        $ret = print " STDERR:\n", @errlines, "\n";
    }
    close $HIS_OUT or croak "unable to close: $HIS_OUT $ERRNO";

    #close $HIS_ERR or croak "unable to close: $HIS_ERR $ERRNO";#bad..todo
    waitpid $childpid, 0;
    if ($CHILD_ERROR) {
        $ret = print "That child exited with wait status of $CHILD_ERROR\n";
    }
    return \@outlines;
}

# access_log => $server->{access_log} || $conf->{default}->{path}->{access_log},
# action_log => $server->{action_log} || $conf->{default}->{path}->{action_log},
#
sub import_sql_and_data {
    print {*STDERR} "Reading DATA ...\n";
    my %contents_of = do { local $/; "", split /_____\[ (\S+) \]_+\n/, <DATA> };

    #    say Dumper \%contents_of;
    for ( values %contents_of ) {
        s/^!=([a-z])/=$1/gxms;
    }
    print {*STDERR} "done\n";
    return \%contents_of;
}

#convert time to human view
sub wdhms {
    my ( $weeks, $days, $hours, $minutes, $seconds, $sign, $res ) =
      qw/0 0 0 0 0/;

    use constant M_IN_HOUR => 60;
    use constant H_IN_DAY  => 24;
    use constant D_IN_WEEK => 7;

    my $EMPTY = q{};
    my $SPACE = q{ };
    my $COMMA = q{,};
    my $QUOTE = q{'};
    my $PLUS  = q{+};
    my $DASH  = q{-};

    $seconds = shift;
    $sign    = $seconds == abs $seconds ? $EMPTY : $DASH;
    $seconds = abs $seconds;

    if ($seconds) {
        ( $seconds, $minutes ) =
          ( $seconds % M_IN_HOUR, int( $seconds / M_IN_HOUR ) );
    }

    if ($minutes) {
        ( $minutes, $hours ) =
          ( $minutes % M_IN_HOUR, int( $minutes / M_IN_HOUR ) );
    }
    if ($hours) {
        ( $hours, $days ) = ( $hours % H_IN_DAY, int( $hours / H_IN_DAY ) );
    }
    if ($days) {
        ( $days, $weeks ) = ( $days % D_IN_WEEK, int( $days / D_IN_WEEK ) );
    }

    if ($weeks)   { $res .= sprintf '%dw ', $weeks }
    if ($days)    { $res .= sprintf '%dd ', $days }
    if ($hours)   { $res .= sprintf '%dh ', $hours }
    if ($minutes) { $res .= sprintf '%dm ', $minutes }
    $res .= sprintf '%ds ', $seconds;

    return $sign . $res;
}

__DATA__

_____[ input.txt ]________________________________________________
Some DOS and dont for travellers.
Take sensible precautions with personal property at all times.
 Dont carry your valuables around with you; take just as much cash as you need. 
 Pick-pockets and thieves may sometimes pose an immediate problem. 
 Never let your handbag or case out of your sight – particularly in restaurants, cinemas, etc. 
 where it is not unknown for bags to vanish from between the feet of their owners. 
 Never leave bags or briefcases unattended in tube or train stations. - 
 They will either be stolen or suspected of being bombs and therefore cause a security alert. 
 Stick to the well-lit streets with plenty of traffic.
 Muggers and rapists prefer poorly lit or isolated places like backstreets , parks, and unmanned railway stations.
 If you avoid these, especially at night, or travel round in group, you should manage to stay out of danger.
Dos:
	Deposit your travelers cheques and valuables in your hotel safeSome DOS and dont for travellers
	Always lock your doors
	Travel in pairs or in groups at night on the Underground
	Remember that both rashness and exaggerated caution are inappropriate
Donts:
	Dont count your money in public
	Dont purchase anything from strangers in the street
	Dont walk along deserted streets or in parks at night
	Dont talk to strangers who try to strike up a conversation with you unless there are other people about.
