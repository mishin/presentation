  use Win32::Unicode::Console;

  my $flaged_utf8_str = "I \x{2665} Perl";

  printW $flaged_utf8_str;
  printfW "[ %s ] :P", $flaged_utf8_str;
  sayW $flaged_utf8_str;
  warnW $flaged_utf8_str;
  dieW $flaged_utf8_str;

  # write file
  printW $fh, $str;
  printfW $fh, $str;
  sayW $fh, $str