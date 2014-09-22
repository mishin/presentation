
PS C:\Users\nmishin\Documents\Padre> cpan POE::Component::IRC::Plugin::AutoJoin
CPAN: CPAN::SQLite loaded ok (v0.199)
Database was generated on Wed, 26 Oct 2011 09:40:28 GMT
Running install for module 'POE::Component::IRC::Plugin::AutoJoin'
Running make for H/HI/HINRIK/POE-Component-IRC-6.74.tar.gz
CPAN: Digest::SHA loaded ok (v5.62)
CPAN: Compress::Zlib loaded ok (v2.037)
Checksum for C:\Strawberry\cpan\sources\authors\id\H\HI\HINRIK\POE-Component-IRC-6.74.tar.gz ok
CPAN: Archive::Tar loaded ok (v1.78)
CPAN: File::Temp loaded ok (v0.22)
CPAN: Parse::CPAN::Meta loaded ok (v1.4401)
CPAN: CPAN::Meta loaded ok (v2.112150)
CPAN: Module::CoreList loaded ok (v2.49)

  CPAN.pm: Building H/HI/HINRIK/POE-Component-IRC-6.74.tar.gz

Checking if your kit is complete...
Looks good
Warning: prerequisite IRC::Utils 0.11 not found.
Writing Makefile for POE::Component::IRC
Writing MYMETA.yml and MYMETA.json
---- Unsatisfied dependencies detected during ----
----   HINRIK/POE-Component-IRC-6.74.tar.gz   ----
    IRC::Utils [requires]
Running make test
  Delayed until after prerequisites
Running make install
  Delayed until after prerequisites
Running install for module 'IRC::Utils'
Running make for H/HI/HINRIK/IRC-Utils-0.12.tar.gz
Checksum for C:\Strawberry\cpan\sources\authors\id\H\HI\HINRIK\IRC-Utils-0.12.tar.gz ok

  CPAN.pm: Building H/HI/HINRIK/IRC-Utils-0.12.tar.gz

Checking if your kit is complete...
Looks good
Writing Makefile for IRC::Utils
Writing MYMETA.yml and MYMETA.json
cp lib/IRC/Utils.pm blib\lib\IRC\Utils.pm
  HINRIK/IRC-Utils-0.12.tar.gz
  C:\Strawberry\c\bin\dmake.EXE -- OK
CPAN: YAML loaded ok (v0.77)
Running make test
C:\strawberry\perl\bin\perl.exe "-MExtUtils::Command::MM" "-e" "test_harness(0, 'blib\lib', 'blib\arch')" t/*.t
t/01_compile.t .... ok
t/02_functions.t .. ok
All tests successful.
Files=2, Tests=47,  0 wallclock secs ( 0.03 usr +  0.11 sys =  0.14 CPU)
Result: PASS
  HINRIK/IRC-Utils-0.12.tar.gz
  C:\Strawberry\c\bin\dmake.EXE test -- OK
Running make install
Installing C:\Strawberry\perl\site\lib\IRC\Utils.pm
Appending installation info to C:\Strawberry\perl\lib/perllocal.pod
  HINRIK/IRC-Utils-0.12.tar.gz
  C:\Strawberry\c\bin\dmake.EXE install UNINST=1 -- OK
Running make for H/HI/HINRIK/POE-Component-IRC-6.74.tar.gz
  Has already been unwrapped into directory C:\Strawberry\cpan\build\POE-Component-IRC-6.74-MRQQx4

  CPAN.pm: Building H/HI/HINRIK/POE-Component-IRC-6.74.tar.gz

cp lib/POE/Component/IRC/State.pm blib\lib\POE\Component\IRC\State.pm
cp lib/POE/Component/IRC/Cookbook/Disconnecting.pod blib\lib\POE\Component\IRC\Cookbook\Disconnecting.pod
cp lib/POE/Component/IRC/Cookbook/Seen.pod blib\lib\POE\Component\IRC\Cookbook\Seen.pod
cp lib/POE/Component/IRC/Cookbook/Resolver.pod blib\lib\POE\Component\IRC\Cookbook\Resolver.pod
cp lib/POE/Component/IRC/Cookbook.pod blib\lib\POE\Component\IRC\Cookbook.pod
cp lib/POE/Component/IRC/Plugin/NickReclaim.pm blib\lib\POE\Component\IRC\Plugin\NickReclaim.pm
cp lib/POE/Component/IRC/Plugin/Console.pm blib\lib\POE\Component\IRC\Plugin\Console.pm
cp lib/POE/Component/IRC/Common.pm blib\lib\POE\Component\IRC\Common.pm
cp lib/POE/Component/IRC/Cookbook/Reload.pod blib\lib\POE\Component\IRC\Cookbook\Reload.pod
cp lib/POE/Component/IRC/Qnet/State.pm blib\lib\POE\Component\IRC\Qnet\State.pm
cp lib/POE/Component/IRC/Plugin/BotTraffic.pm blib\lib\POE\Component\IRC\Plugin\BotTraffic.pm
cp lib/POE/Component/IRC/Plugin/CycleEmpty.pm blib\lib\POE\Component\IRC\Plugin\CycleEmpty.pm
cp lib/POE/Component/IRC/Cookbook/Hailo.pod blib\lib\POE\Component\IRC\Cookbook\Hailo.pod
cp lib/POE/Component/IRC/Plugin/NickServID.pm blib\lib\POE\Component\IRC\Plugin\NickServID.pm
cp lib/POE/Component/IRC/Plugin/PlugMan.pm blib\lib\POE\Component\IRC\Plugin\PlugMan.pm
cp lib/POE/Component/IRC/Plugin/ISupport.pm blib\lib\POE\Component\IRC\Plugin\ISupport.pm
cp lib/POE/Component/IRC/Cookbook/BasicBot.pod blib\lib\POE\Component\IRC\Cookbook\BasicBot.pod
cp lib/POE/Component/IRC/Plugin/Whois.pm blib\lib\POE\Component\IRC\Plugin\Whois.pm
cp lib/POE/Component/IRC/Plugin/Logger.pm blib\lib\POE\Component\IRC\Plugin\Logger.pm
cp lib/POE/Component/IRC/Cookbook/Gtk2.pod blib\lib\POE\Component\IRC\Cookbook\Gtk2.pod
cp lib/POE/Component/IRC/Plugin/CTCP.pm blib\lib\POE\Component\IRC\Plugin\CTCP.pm
cp lib/POE/Filter/IRC.pm blib\lib\POE\Filter\IRC.pm
cp lib/POE/Component/IRC/Plugin/DCC.pm blib\lib\POE\Component\IRC\Plugin\DCC.pm
cp lib/POE/Component/IRC/Plugin/FollowTail.pm blib\lib\POE\Component\IRC\Plugin\FollowTail.pm
cp lib/POE/Component/IRC/Plugin/Proxy.pm blib\lib\POE\Component\IRC\Plugin\Proxy.pm
cp lib/POE/Filter/IRC/Compat.pm blib\lib\POE\Filter\IRC\Compat.pm
cp lib/POE/Component/IRC/Cookbook/Translator.pod blib\lib\POE\Component\IRC\Cookbook\Translator.pod
cp lib/POE/Component/IRC/Plugin/AutoJoin.pm blib\lib\POE\Component\IRC\Plugin\AutoJoin.pm
cp lib/POE/Component/IRC/Plugin/BotAddressed.pm blib\lib\POE\Component\IRC\Plugin\BotAddressed.pm
cp lib/POE/Component/IRC/Plugin.pm blib\lib\POE\Component\IRC\Plugin.pm
cp lib/POE/Component/IRC/Constants.pm blib\lib\POE\Component\IRC\Constants.pm
cp lib/POE/Component/IRC/Plugin/BotCommand.pm blib\lib\POE\Component\IRC\Plugin\BotCommand.pm
cp lib/POE/Component/IRC/Projects.pod blib\lib\POE\Component\IRC\Projects.pod
cp lib/POE/Component/IRC/Qnet.pm blib\lib\POE\Component\IRC\Qnet.pm
cp lib/POE/Component/IRC.pm blib\lib\POE\Component\IRC.pm
cp lib/POE/Component/IRC/Plugin/Connector.pm blib\lib\POE\Component\IRC\Plugin\Connector.pm
  HINRIK/POE-Component-IRC-6.74.tar.gz
  C:\Strawberry\c\bin\dmake.EXE -- OK
Running make test
C:\strawberry\perl\bin\perl.exe "-MExtUtils::Command::MM" "-e" "test_harness(0, 'blib\lib', 'blib\arch')" t/01_base/*.t
t/02_behavior/*.t t/03_subclasses/*.t t/04_plugins/01_ctcp/*.t t/04_plugins/02_connector/*.t t/04_plugins/03_botaddresse
d/*.t t/04_plugins/04_bottraffic/*.t t/04_plugins/05_isupport/*.t t/04_plugins/06_plugman/*.t t/04_plugins/07_console/*.
t t/04_plugins/08_proxy/*.t t/04_plugins/09_nickreclaim/*.t t/04_plugins/10_followtail/*.t t/04_plugins/11_cycleempty/*.
t t/04_plugins/12_autojoin/*.t t/04_plugins/13_botcommand/*.t t/04_plugins/14_logger/*.t t/04_plugins/15_nickservid/*.t
t/04_plugins/16_whois/*.t t/04_plugins/17_dcc/*.t t/05_regression/*.t
t/01_base/01_compile.t ............................. ok
t/01_base/02_filters.t ............................. ok
t/01_base/04_pocosi.t .............................. ok
t/02_behavior/01_public_methods.t .................. ok
t/02_behavior/02_connect.t ......................... ok
t/02_behavior/03_socketerr.t ....................... ok
t/02_behavior/04_ipv6.t ............................ skipped: Socket6 is needed for IPv6 tests
t/02_behavior/05_resolver.t ........................ ok
t/02_behavior/06_online.t .......................... ok
t/02_behavior/07_subclass.t ........................ ok
t/02_behavior/08_parent_session.t .................. ok
t/02_behavior/09_multiple.t ........................ ok
t/02_behavior/10_signal.t .......................... ok
t/02_behavior/11_multi_signal.t .................... ok
t/02_behavior/12_delays.t .......................... ok
t/02_behavior/13_activity.t ........................ ok
t/02_behavior/14_newline.t ......................... ok
t/02_behavior/15_no_stacked_ctcp.t ................. ok
t/02_behavior/16_nonclosing_ctcp.t ................. ok
t/02_behavior/17_raw.t ............................. ok
t/02_behavior/18_shutdown.t ........................ ok
t/03_subclasses/01_state.t ......................... ok
t/03_subclasses/02_qnet.t .......................... ok
t/03_subclasses/03_qnet_state.t .................... ok
t/03_subclasses/04_netsplit.t ...................... 3/43
#   Failed test 'Timed out'
#   at t/03_subclasses/04_netsplit.t line 86.
t/03_subclasses/04_netsplit.t ...................... 35/43 # Looks like you planned 43 tests but ran 36.
# Looks like you failed 1 test of 36 run.
t/03_subclasses/04_netsplit.t ...................... Dubious, test returned 1 (wstat 256, 0x100)
Failed 8/43 subtests
t/03_subclasses/05_state_awaypoll.t ................ ok
t/03_subclasses/06_state_nick_sync.t ............... ok
t/04_plugins/01_ctcp/01_load.t ..................... ok
t/04_plugins/01_ctcp/02_replies.t .................. ok
t/04_plugins/02_connector/01_load.t ................ ok
t/04_plugins/02_connector/02_reconnect.t ........... ok
t/04_plugins/03_botaddressed/01_load.t ............. ok
t/04_plugins/03_botaddressed/02_output.t ........... ok
t/04_plugins/04_bottraffic/01_load.t ............... ok
t/04_plugins/04_bottraffic/02_output.t ............. ok
t/04_plugins/05_isupport/01_load.t ................. ok
t/04_plugins/05_isupport/02_isupport.t ............. ok
t/04_plugins/06_plugman/01_load.t .................. ok
t/04_plugins/06_plugman/02_add.t ................... ok
t/04_plugins/06_plugman/03_irc_interface.t ......... ok
t/04_plugins/06_plugman/04_auth_sub.t .............. ok
t/04_plugins/07_console/01_load.t .................. ok
t/04_plugins/08_proxy/01_load.t .................... ok
t/04_plugins/08_proxy/02_connect.t ................. ok
t/04_plugins/09_nickreclaim/01_load.t .............. ok
t/04_plugins/09_nickreclaim/02_reclaim.t ........... ok
t/04_plugins/09_nickreclaim/03_immediate_change.t .. ok
t/04_plugins/09_nickreclaim/04_immediate_quit.t .... ok
t/04_plugins/10_followtail/01_load.t ............... ok
t/04_plugins/11_cycleempty/01_load.t ............... ok
t/04_plugins/11_cycleempty/02_cycle.t .............. ok
t/04_plugins/12_autojoin/01_load.t ................. ok
t/04_plugins/12_autojoin/02_join.t ................. ok
t/04_plugins/12_autojoin/03_banned.t ............... ok
t/04_plugins/12_autojoin/04_kicked.t ............... ok
t/04_plugins/12_autojoin/05_password.t ............. ok
t/04_plugins/12_autojoin/06_kick_ban_password.t .... ok
t/04_plugins/13_botcommand/01_load.t ............... ok
t/04_plugins/13_botcommand/02_commands.t ........... ok
t/04_plugins/13_botcommand/03_options.t ............ ok
t/04_plugins/13_botcommand/04_help.t ............... ok
t/04_plugins/13_botcommand/05_auth_sub.t ........... ok
t/04_plugins/13_botcommand/06_prefix.t ............. ok
t/04_plugins/13_botcommand/07_bare_private.t ....... ok
t/04_plugins/13_botcommand/08_nonword.t ............ ok
t/04_plugins/14_logger/01_load.t ................... ok
t/04_plugins/14_logger/02_public.t ................. ok
t/04_plugins/14_logger/03_private.t ................ ok
t/04_plugins/14_logger/04_dcc_chat.t ............... 1/13 _dcc_failed: Unknown wheel ID: 10
