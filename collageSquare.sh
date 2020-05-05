#! /bin/sh
#
# collage-maker - create nice image collages
#
# (c) 2020 by tmez030
#

### parameters
# size of the resulting image in pixels
G=2800
# number of rows/columns (requires n^2 source images)
n=3
# margin (as a percentage)
p=0

let c='100*G / ((n+1)*p + 100*n)'
let s='(G - n*c) / (n+1)'

echo Size of single cover: $c px
echo Size of separator: $s px

i=0
for dat in input/*.jp*g
do
   files[$i]=$dat
   let i='i+1'
done
let filesNeeded='n*n'
if [ $filesNeeded -le ${#files[@]} ]
then
   echo Using ${#files[@]} cover files
else
   echo Not enough files: $filesNeeded but only ${#files[@]} found
   exit 1
fi

ppmmake black $G $G > base.ppm

j=0
k=0
while [ $j -lt $n ]
do
   let y='(j+1)*s+j*c'
   i=0
   while [ $i -lt $n ]
   do
      let x='(i+1)*s+i*c'
      echo ${files[k]}
      jpegtopnm "${files[k]}" | pamscale -xyfill $c $c | pamcut -width $c -height $c > small.ppm
      pnmpaste small.ppm $x $y base.ppm > base2.ppm
      mv base2.ppm base.ppm
      let i='i+1'
      let k='k+1'
   done
   let j='j+1'
done

pnmtojpeg -quality=90 -optimize base.ppm > base.jpg
rm base.ppm small.ppm

# Playlists:
djpeg -pnm base.jpg | pnmrotate 20 | pamcut -left 800 -top 800 -right -800 -bottom -800 | pamscale -width=800 | pnmtojpeg -quality=90 > test.jpg

