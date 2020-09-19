#!/bin/bash

FOR='Larry Wall'
FILE=larry
AUTHOR='randyl'
CMD='raku -I../lib ../bin/maze-booklet'

# Remove any existing PDFs from a previous run.
rm -f *.pdf

# Cover
$CMD --type=cover --for="$FOR" --author="$AUTHOR"

# Letters
$CMD --type=mask --image=../masks/L.png --name='L'  --resize-factor=0.1 --cell-size=15 --style='font-size: 55%;'
$CMD --type=mask --image=../masks/A.png --name='A'  --resize-factor=0.1 --cell-size=15 --style='font-size: 55%;'
$CMD --type=mask --image=../masks/R.png --name='R1' --resize-factor=0.1 --cell-size=15 --style='font-size: 55%;'
$CMD --type=mask --image=../masks/R.png --name='R2' --resize-factor=0.1 --cell-size=15 --style='font-size: 55%;'
$CMD --type=mask --image=../masks/Y.png --name='Y'  --resize-factor=0.1 --cell-size=15 --style='font-size: 55%;'

# Shapes
$CMD --type='circle' --rows=11 --cell-size=30 --name='circle-medium' --style='font-size: 85%;'
$CMD --type='grid' --cell='square' --rows=20 --columns=20 --cell-size=25 --name='square-medium' --style='font-size: 75%;'
$CMD --type='grid' --cell='hex' --rows=16 --columns=16 --cell-size=20 --name='hex-medium' --style='font-size: 75%;'
$CMD --type='grid' --cell='triangle' --rows=30 --columns=40 --cell-size=25 --name='triangle-medium' --style='font-size: 50%;'
$CMD --type='weave' --rows=20 --columns=16 --cell-size=35 --name='weave-medium' --style='font-size: 65%;'

# Cube
$CMD --type='cube' --rows=10 --cell-size=20 --name='cube-medium' --landscape --style='font-size: 75%;'

# Create maze packet
pdftk $(ls -rt *.pdf | grep -v 'solution.pdf') cat output "$FILE.pdf"

# Create solution packet
pdftk $(ls -rt *-solution.pdf) cat output "$FILE-solution.pdf"
