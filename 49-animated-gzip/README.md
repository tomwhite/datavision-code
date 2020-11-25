# Animated gzip

This visualization was inspired by [gzthermal](https://encode.su/threads/1889-gzthermal-pseudo-thermal-view-of-Gzip-Deflate-compression-efficiency),
a command line tool that produces a heatmap image for gzipped files. It helps you see which parts of the file compress well (blue) and which don't (red/black).

To generate an animated gzip visualization of a gzipped file, you need to download
[defdb](https://encode.su/threads/1428-defdb-a-tool-to-dump-the-deflate-stream-from-gz-and-png-files),
a companion tool to gzthermal that dumps a deflate stream as a text representation.

Run defdb on a gzipped file (note that this only works well for small files):

    defdb -d data/2020-03-11-11-hamilton-songs.md.gz > data/animated-gzip-hamilton.txt

Then the HTML page _animated-gzip.html_ reads the text representation to produce an animated visualization of the compression.
(You can edit it to change the name of the input file if you called it something else in the previous step.)

    http-server

Open http://localhost:8080/animated-gzip.html to see the animation.
