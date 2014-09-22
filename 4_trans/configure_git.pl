#!/usr/bin/perl
#
#
# Configure basic git settings
#

use Modern::Perl;
use IO::Prompt::Tiny qw( prompt );
use File::HomeDir;
use File::Spec::Functions qw(catdir catfile);

say "Configuration for global work using git";

my $user = prompt( 'Please write your Github user name:', getlogin() );
chomp $user;


my $email = prompt( 'Please write your Github email address:', '' );
chomp $email;


system('git', 'config', '--global', 'user.name',	$user	);
system('git', 'config', '--global', 'user.email',	$email	);
system('git', 'config', '--global', 'push.default',	'tracking'	);
system('git', 'config', '--global', 'pack.threads',	0	);
system('git', 'config', '--global', 'core.autocrlf',	'false'	);
system('git', 'config', '--global', 'apply.whitespace',	'nowarn'	);
system('git', 'config', '--global', 'color.ui',	'auto'	);
system('git', 'config', '--global', 'core.excludesfile',catfile(home(),'.gitignore'));
system('git', 'config', '--global', 'alias.up',	'pull --rebase'	);
