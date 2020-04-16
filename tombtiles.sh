#!/bin/bash

SOURCEDIR=./generated/US

swap_coords() {
    remove_swapped
    for dir in $SOURCEDIR/*/ ; do
        mbdir="mbtiles/$(basename $dir)"
        [ ! -d "$SOURCEDIR/$mbdir" ] && mkdir $SOURCEDIR/$mbdir
        for file in $dir*.geojson; do
            filefull=$(basename -- "$file")
            extension="${filefull##*.}"
            filename="${filefull%.*}"
            [ ! -f $dir$filename-swapped.geojson ] && python swapgeojson.py -f $file
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
            [ ! -f $dir$filename-swapped.geojson ] && python swapgeojson.py -f $file &&
            echo "Generating mbtiles"
            tippecanoe -zg -o $SOURCEDIR/$mbdir/$filename.mbtiles --drop-densest-as-needed $dir$filename-swapped.geojson &&
            echo "Converted $file to $SOURCEDIR/$mbdir/$filename.mbtiles"
            [ -f "$dir$filename-swapped.geojson" ] && rm $dir$filename-swapped.geojson
            echo ""
        done
    done
}

to_mbtiles;