#!/bin/bash
# A VERY dirty script to patch the tools/src of SPEC CPU 2006.
# This script should be run in the tools/src dir
echo "Fixing the source of SPEC CPU 2006 V1.2 tools/src."
mv -v ../buildtools ../buildtools.bak && cp -v ./buildtools ../
mv -v ../make-3.82/glob/glob.c ../make-3.82/glob/glob.c.bak && cp -v ./make-3.82/glob/glob.c ../make-3.82/glob/glob.c
mv -v ../specsum/gnulib/stdio.in.h ../specsum/gnulib/stdio.in.h.bak && cp -v ./specsum/gnulib/stdio.in.h ../specsum/gnulib/stdio.in.h
mv -v ../tar-1.25/gnu/stdio.in.h ../tar-1.25/gnu/stdio.in.h.bak && cp -v ./tar-1.25/gnu/stdio.in.h  ../tar-1.25/gnu/stdio.in.h
for dir in expat-2.0.1/conftools/ make-3.82/config/ rxp-1.5.0/ specinvoke/ specsum/build-aux/ tar-1.25/build-aux/ xz-5.0.0/build-aux
do
    mv -v ../${dir}/config.guess ../${dir}/config.guess.bak && cp -v config.guess ../${dir}/
    mv -v ../${dir}/config.sub ../${dir}/config.sub.bak && cp -v config.sub ../${dir}/
done
echo "Done!"
