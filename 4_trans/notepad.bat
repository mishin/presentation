start "" /d"%~dp0..\Programm\Notepad++" "notepad++.exe"
ping -n 2 127.0.0.1 > nul
"%~dp0..\nircmdc.exe" sendkeypress ctrl+shift+f