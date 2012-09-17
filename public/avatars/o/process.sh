#!/bin/sh
for file in *.png; do convert $file -trim -gravity center -extent 120x120 -resize 32x32 ../s/$file; done
