@ECHO OFF
FOR /F %%i IN ('dir /b "*.mov"') DO (
echo Encoding %%i to %%~ni.mp4 using h264 codec...
ffmpeg -i %%i -vcodec h264 -acodec copy %%~ni.mp4
)
