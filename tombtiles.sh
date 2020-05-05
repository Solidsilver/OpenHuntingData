#!/bin/bash

SOURCEDIR=./generated/US

swap_coords() {
    echo "Swapping Coords"
    # rm -r $SOURCEDIR/swapped
    # mkdir $SOURCEDIR/swapped
    [ ! -d "$SOURCEDIR/swapped" ] && mkdir $SOURCEDIR/swapped
    for dir in $SOURCEDIR/*/ ; do
        swpdir="swapped/$(basename $dir)"
        [ ! -d "$SOURCEDIR/$swpdir" ] && mkdir $SOURCEDIR/$swpdir
        for file in $dir*.geojson; do
            filefull=$(basename -- "$file")
            extension="${filefull##*.}"
            filename="${filefull%.*}"
            # echo "[dir:$dir][swpdir:$swpdir][filename:$filename][file:$file]"
            [ ! -f $SOURCEDIR/$swpdir/$filename.geojson ] && python swapgeojson.py -f $file -o $SOURCEDIR/$swpdir && echo "Swapped $swpdir"
        done
    done
}

remove_swapped() {
    # Remove swapped files.
    for dir in $SOURCEDIR/*/ ; do
        for file in $(ls $dir | grep swapped); do
            echo "Removing" $dir$file
            rm $dir$file
        done
    done
    
}


to_mbtiles() {
    [ ! -d "$SOURCEDIR/mbtiles" ] && mkdir $SOURCEDIR/mbtiles
    
    remove_swapped
    
    for dir in $SOURCEDIR/*/ ; do
        mbdir="mbtiles/$(basename $dir)"
        [ ! -d "$SOURCEDIR/$mbdir" ] && mkdir $SOURCEDIR/$mbdir
        for file in $dir*.geojson; do
            filefull=$(basename -- "$file")
            extension="${filefull##*.}"
            filename="${filefull%.*}"
            [ ! -f $SOURCEDIR/$mbdir/$filename.mbtiles ] && python swapgeojson.py -f $file -l &&
            echo "Generating mbtiles"
            tippecanoe -zg -o $SOURCEDIR/$mbdir/$filename.mbtiles --drop-densest-as-needed -n "$filename" $dir$filename-swapped.geojson &&
            echo "Converted $file to $SOURCEDIR/$mbdir/$filename.mbtiles"
            [ -f "$dir$filename-swapped.geojson" ] && rm $dir$filename-swapped.geojson
            echo ""
        done
    done
}

swap_coords;
# to_mbtiles;