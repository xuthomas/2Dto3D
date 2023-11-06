SETLOCAL
set clipDelay=0.04
set /A factor3D=20
set factorTimeOffset=%clipDelay%
set encoder=hevc_nvenc
set rateControl=cbr
set bitRate=15M
set minBitRate=15M
set maxBitRate=15M
set bufferSize=512K

for /f "delims=" %%A in (%1) do (
    set "outfilepath=%%~dpnA"
)


REM The line below is intended to extract the width and height of the video.
REM Comment the line out and set the videoW and videoH variables explicitly if this does not work for your video.
for /f "delims=" %%a in ('ffprobe -hide_banner -show_streams %1 2^>nul ^| findstr "^width= ^height="') do set "mypicture_%%a"

set videoW=%mypicture_width%
set videoH=%mypicture_height%

set /A ResW=%videoW%+%videoW%/%factor3D%
set /A ResH=%videoH%+%videoH%/%factor3D%
set /A CropW=(%ResW%-%videoW%)/2
set /A CropH=%videoH%/(2*%factor3D%)

ffmpeg -i %1 -filter_complex "[0:v]trim=start=%clipDelay%,setpts=PTS-STARTPTS,scale=%ResW%:%ResH%,crop=%videoW%:%videoH%:0:%CropH%[right];[0:v]scale=%ResW%:%videoH%,crop=%videoW%:%videoH%:%CropW%:%CropH%[left];[right][left]hstack" -c:v %encoder% -rc %rateControl% -b:v %bitRate% -minrate %minBitRate% -maxrate %maxBitRate% -bufsize %bufferSize% "%outfilepath%.SBS.mp4"

EXIT /B
