@ECHO off
SETLOCAL enabledelayedexpansion

if /i "%~2###"=="###" (
	move /y "%~1size_test.txt" "%~1size.txt"
	exit /b
)

set "outs=0"

echo/Проверка необходимости обновления...
"%~dp0wget.exe" --spider "%~2" -o"%~1log.txt"
type "%~1log.txt" | find /i  "Length" >"%~1size_test.txt"
DEL /f /q "%~1log.txt"

if exist "%~1size.txt" (
	fc /C /W "%~1size_test.txt" "%~1size.txt">nul
	if !ERRORLEVEL!==0 (
		echo/Обновление не требуется.
		set "outs=1"
		DEL /f /q "%~1size_test.txt"
	)
)

endlocal & set /a %3=%outs%