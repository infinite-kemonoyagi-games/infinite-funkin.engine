#!/bin/bash

echo "Friday Night Funkin' Infinite Engine | Chart Convertor"
echo ""

read -p "Path of the song: " input
echo "Input: $input"
echo ""

read -p "Path of the result files (leave this blank to import files in the current path): " output
echo "Output: $output"
echo ""

haxe --run SongConvertor "$input"
read -p "Press Enter to exit..."
