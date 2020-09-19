As a way to learn the [Raku language](https://raku.org/), I worked through the book 
*[Mazes for Programmers](https://pragprog.com/titles/jbmaze/mazes-for-programmers/)* by Jamis Buck, 
rewriting all the maze algorithms into Raku. I then wrote a program to create a PDF of a "Booklet O' Mazes"
for all the kids in my extended family.

This repository contains:
- Raku versions of the maze algorithms and grids from *Mazes for Programmers*. Mazes are generated
  as SVG instead of PNG used in the book.
- The Raku program `bin/maze-booklet` to generate a PDF of mazes.
- An example bash script `examples/larry.sh` (for Larry Wall) showing how to generate a booklet, along with
  the resulting booklet [`examples/larry.pdf`](https://github.com/randyl/maze-booklet/blob/master/examples/larry.pdf) and its solutions [`examples/larry-solution.pdf`](https://github.com/randyl/maze-booklet/blob/master/examples/larry-solution.pdf).

The code in this repository requires the following Raku modules:
- SVG
    - To generate mazes as SVG.
- GD::Raw
    - To parse image masks and turn them into mazes.
- Image::Resize
    - To resize image masks as needed.

And the following programs are also required:
- google-chrome
    - To convert HTML/SVG files to PDF via --headless mode.
- pdftk
    - To combine multiple PDFs into a single file.
