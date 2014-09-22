"%~dp0..\nircmdc.exe" execmd attrib -r -s "%WINDIR%\SYSTEM32\drivers\etc\hosts"
START "" /W /d"%~dp0..\Programm\Notepad++" "notepad++.exe" "%WINDIR%\SYSTEM32\drivers\etc\hosts"
"%~dp0..\nircmdc.exe" execmd attrib +r +s "%WINDIR%\SYSTEM32\drivers\etc\hosts"