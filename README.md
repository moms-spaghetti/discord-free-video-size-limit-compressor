# discord-free-video-size-limit-compressor

## requirements
- nvidia gpu
- windows
- ffmpeg installed

## functionality
- compress video files to meet discord free video upload limit of 10MB
- output file is h264 (why h264? for compatibility, discord still doesn't seem to play h265/h266/av1 correctly in the stable build or on mobile)
- optional lower quality setting for larger files

## set the config
there is a variable in compressor.bat called `DEFAULT_AUDIO_BOOST` it is the audio boost value for converted files. Default setting is +22db, set this to whatever you require.

## install ffmpeg  
https://ffmpeg.org/download.html

after confirm ffmpeg correctly installed on the path, open `cmd` and type:
```batch
ffmpeg
```
you should see:
```batch 
ffmpeg version 7.1-essentials_build-www.gyan.dev Copyright (c) 2000-2024 the FFmpeg developers
...
```
if you don't you'll need to add ffmpeg to the path, search `add ffmpeg to path windows`

## args 
|position|arg|desc|example|required|
|---|---|---|---|---|
|0|filepath|full path to your file|c:\videos\myvideofile.mp4|yes|
|1|video_scale|reduce output quality, leave blank to output original resolution, choose from list of supported output resolutions below, audio quality is lowered from 128Kbps to 96Kbps|640|no|
|2|audio_boost|increase the audio volume of the output in dB from 1 to 30|6|no|

- if audio_boost is required but video_scale is not, it can be skipped with an underscore `_` 
- if file path or file name includes spaces surround it in double quotes - example `"c:\videos\myvideofile.mp4"`

## supported video_scale values 
Use of these as the quality arg
- 1440
- 1080
- 900
- 720
- 640
- 540
- 480
- 360

## supported audio_boost values 
Range from `1` to `30`

## run examples
```batch
// original resolution using the the default_audio_boost value 
compressor.bat "c:\Videos\video.mp4" 


// resolution downscaled to 720p
compressor.bat "c:\Videos\video.mp4" 720


// resolution downscaled to 540p
compressor.bat "c:\Videos\video.mp4" 540


// resolution downscaled to 540p and audio boosted by 6dB
compressor.bat "c:\Videos\video.mp4" 540 6


// resolution downscaled to 1080p and audio boosted by 30dB
compressor.bat "c:\Videos\video.mp4" 1080 30


// original resolution and audio boosted by 30dB
compressor.bat "c:\Videos\video.mp4" _ 30
```

## notes
- With larger files quality will degrade. Try reducing video_scale to increase the output bitrate.
- The video_scale value will perform better when matched to the input file aspect ratio.
- A valid value in video_scale will decrease audio bitrate from 128Kbps to 96Kbps to improve output file size. 

## tip if this helped
https://paypal.me/woahtherekitty