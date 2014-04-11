@ECHO OFF
echo %1 | findstr "\" >nul 2>&1
IF %ERRORLEVEL% == 0 ( 
SET INFILE=%1
GOTO CONVERT
)
SET INFILE="%1"
:CONVERT
SET RAND=%RANDOM%
ffmpeg -i %INFILE% -vcodec copy -b:a 256k -map 0:0 -map 0:1 -map 0:1 -map_channel 0.1.0:0.1 -map_channel 0.1.1:0.1 -map_channel 0.1.2:0.2 -map_channel 0.1.3:0.2 -strict -2 -metadata:s:a:0 language=ukr -metadata:s:a:1 language=rus %RAND%.m2ts >nul 2>&1
IF %ERRORLEVEL% == 0 GOTO MOVE
IF %ERRORLEVEL% == 9009 GOTO ALERT_BINARY_NOT_FOUND
IF %ERRORLEVEL% == 1260 GOTO ALERT_BLOCKED_BY_GROUPPOLICY
IF %ERRORLEVEL% == 1 GOTO ALERT_CHANNELS_FAILURE
GOTO ALERT_DEFAULT
:MOVE
move /Y %RAND%.m2ts %INFILE:~0,-6%.mp4"
del %INFILE%
GOTO END
:ALERT_BINARY_NOT_FOUND
msg %username% "ffmpeg binary not found!"
GOTO END
:ALERT_BLOCKED_BY_GROUPPOLICY
msg %username% "ffmpeg launch is blocked by AD group policy!"
GOTO END
:ALERT_CHANNELS_FAILURE
msg %username% "Input file has only 2 audio channels. Conversion failed!"
GOTO END
:ALERT_DEFAULT
msg %username% "Something went wrong. Please contact system administrator."
:END
