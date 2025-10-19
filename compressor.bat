@echo off
setlocal EnableDelayedExpansion

:: set these 
set "DEFAULT_AUDIO_BOOST=22"

:: config
set "PROBE_RES="
set "TARGET_MB=9"
set "AUDIO_KBPS=128"
set "AUDIO_VOLUME=-af volume=0dB"
set "SCALE_FILTER="
set "INPUT=%~1"
set "FILENAME=%~n1"
set "EXTENSION=%~x1"
set "OUTPUT=%FILENAME%_encoded%EXTENSION%"

:: errors
set "ERR_USAGE=ERR_USAGE: compressor.bat filepath.mp4 [video_scale] [audio_boost]"
set "ERR_NO_FILE_NAME=ERR_NO_FILE_NAME: must provide a full path to a valid file"
set "ERR_SCALE_FILTER_UNKNOWN=ERR_SCALE_FILTER_UNKNOWN: video_scale argument unknown"
set "ERR_AUDIO_VOLUME_NAN=ERR_AUDIO_VOLUME_NAN: audio_boost argument not a number"
set "ERR_AUDIO_VOLUME_OUT_OF_RANGE=ERR_AUDIO_VOLUME_OUT_OF_RANGE: audio_boost argument out of range"

:: messages
set "MSG_SCALE_FILTER_VALUES=MSG_SCALE_FILTER_VALUES: video_scale supported values 1080,720,640,540,480"
set "MSG_SCALE_FILTER_IGNORE=MSG_SCALE_FILTER_IGNORE: video_scale if only applying audio_boost pass an underscore _"
set "MSG_AUDIO_VOLUME_VALUES=MSG_AUDIO_VOLUME_VALUES: audio_boost supported values between 1-30"

:: video file width
set "CMD=ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "%INPUT%""
for /f "usebackq delims=" %%a in (`!CMD!`) do set "PROBE_RES=%%a"

:: file
if "%~1"=="" (
    echo %ERR_USAGE% 
    echo %ERR_NO_FILE_NAME%
    exit /b 1
)

:: video size
if "%~2"=="" (
	set "SCALE_FILTER=-vf scale=-2:%PROBE_RES%"
) else if "%~2"=="_" (
		set "SCALE_FILTER=-vf scale=-2:%PROBE_RES%"
	) else (
		set "AUDIO_KBPS=96"
			if /i "%~2"=="1440" (
				set "SCALE_FILTER=-vf scale=-2:1440"
			) else if /i "%~2"=="1080" (
				set "SCALE_FILTER=-vf scale=-2:1080"
			) else if /i "%~2"=="900" (
				set "SCALE_FILTER=-vf scale=-2:900"
			) else if /i "%~2"=="720" (
				set "SCALE_FILTER=-vf scale=-2:720"
			) else if /i "%~2"=="640" (
				set "SCALE_FILTER=-vf scale=-2:640"
			) else if /i "%~2"=="540" (
				set "SCALE_FILTER=-vf scale=-2:540"
			) else if /i "%~2"=="480" (
				set "SCALE_FILTER=-vf scale=-2:480"
			) else if /i "%~2"=="360" (
				set "SCALE_FILTER=-vf scale=-2:360"
			) else (
				echo %ERR_SCALE_FILTER_UNKNOWN%
				echo %MSG_SCALE_FILTER_VALUES%
				echo %MSG_SCALE_FILTER_IGNORE%
				exit /b 1 
	)
)

:: audio volume
if "%~3"=="" (
	set "AUDIO_VOLUME=-af volume=%DEFAULT_AUDIO_BOOST%dB"
) else if "%~3"=="_" (
	set "AUDIO_VOLUME=-af volume=%DEFAULT_AUDIO_BOOST%dB"
) else (
    set "VOLUME_ARG=%~3"

    :: test if number
    set /a TEST_NUM=0 + !VOLUME_ARG! >nul 2>&1
    if errorlevel 1 (
        echo %ERR_AUDIO_VOLUME_NAN%
        echo %MSG_AUDIO_VOLUME_VALUES%
        exit /b 1
    )

    :: test range
    set /a TEST_VOLUME=!VOLUME_ARG! 2>nul

    if !TEST_VOLUME! GTR 30 (
        echo %ERR_AUDIO_VOLUME_OUT_OF_RANGE%
        echo %MSG_AUDIO_VOLUME_VALUES%
        exit /b 1
    )

    if !TEST_VOLUME! LSS 1 (
        echo %ERR_AUDIO_VOLUME_OUT_OF_RANGE%
        echo %MSG_AUDIO_VOLUME_VALUES%
        exit /b 1
    )


    set "AUDIO_VOLUME=-af volume=!TEST_VOLUME!dB"
)

:: duration
for /f %%a in ('ffprobe -v error -select_streams v:0 -show_entries format^=duration -of default^=noprint_wrappers^=1:nokey^=1 "%INPUT%"') do set "DURATION=%%a"

:: remove decimal
for /f "tokens=1 delims=." %%b in ("%DURATION%") do set "DURATION=%%b"

:: eval bitrate
set /a TOTAL_KBPS=%TARGET_MB%*8389/%DURATION%
set /a SAFE_TOTAL_KBPS=%TOTAL_KBPS% * 85 / 100
set /a VIDEO_KBPS=%SAFE_TOTAL_KBPS% - %AUDIO_KBPS%
set /a BUF_KBPS=%VIDEO_KBPS%

echo encode
ffmpeg -y -i "%INPUT%" -c:v h264_nvenc -rc cbr -preset slow ^
-b:v %VIDEO_KBPS%k -maxrate %VIDEO_KBPS%k -bufsize %BUF_KBPS%k ^
-c:a aac -b:a %AUDIO_KBPS%k %AUDIO_VOLUME% %SCALE_FILTER% "%OUTPUT%"


:: 1st pass logs remove
del ffmpeg2pass-0.log 2>nul
del ffmpeg2pass-0.log.mbtree 2>nul


endlocal
