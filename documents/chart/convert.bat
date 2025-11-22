@echo off
echo FNF INFIENGINE SONG CONVERTOR
set /p input= Path of the song 
echo Path: %input%
haxe --run SongConverter %input%
pause
