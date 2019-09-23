#!/bin/bash
# 
# Copyright (c) 2019, Luis Quesada Torres - https://github.com/lquesada | www.luisquesada.com
#
# This script takes as input a set of MagicaVoxel vox files and a set of
# exported .obj/.mtl/.png files, and creates copies of the .obj/.mtl/.png files
# named after the objects. MagicaVoxel defaults to exporting with names such as
# "test-1.obj", "test-1.mtl", "test-1.png", "test-2.obj", "test-2.mtl", etc.
#
# Disclaimer: This is a very hacky script. It is quite flaky and it works based
# on some assumptioms. Use at your own risk. Before using, please check the
# README.md and LICENSE files at
# https://github.com/lquesada/voxel-3d-models/tools/voxobjrename 
#
# Prepare the input like this:
#
# - a "vox" subdirectory that contains one or more MagicaVoxel .vox files
#
#   ALL object names must start and end with "_VGCX_"
#
#   For example, valid names are: "_VGCX_dog_VGCX_" or "_VGCX_animal/dog_VGCX_"
#   Please note that the name can contain "/" to specify subdirectories.
#
#   Objects with _VGIGNORE_ in the name will be ignored. Please note that the
#   object names must still start and end with _VGCX_.
#
#   For example, object "_VGCX__VGIGNORE_placeholder_VGCX_" will be ignored
#
# - an "export" subdirectory that contains all the exported .obj/.mtl/.png
#   files for all the vox files above
#
#   These files must be exported using MagicaVoxel 0.99.2. Later versions alter
#   the center coordinates to maintain the scene in one piece, but we do want
#   to export all models centered
#
#   A common source of flakiness is to have more or less .obj/.mtl/.png files
#   than objects are in the .vox files, so double check if something goes wrong
#
# Run the script like this: $ bash voxobjrename.sh
#
# The script will process the "vox" and "export" subdirectories
# non-destructively and generate an "output" directory where .obj/.mtl/.png
# files have the proper name, e.g. "dog.obj", "dog.mtl", "dog.png".
#
# The script also edits some values in the mtl files so that the texture is
# imported correctly from some software. Feel free to tweak or remove the
# overrides if they don't work for you.

set -e

err_report() {
    echo "Error on line $1"
}

trap 'err_report $LINENO' ERR

rm -rf output
mkdir output

for x in $(cd vox;ls *.vox);do
  file=`echo $x | sed s/'\.vox$'//g`
  i=0
  # Let's use _VGCX_ as a marker for beginning and end of object name so we can use strings to get all objects.
  for f in `strings vox/$file.vox | grep -e VGCX | sed s/'^.*GCX_\(.*\)_VGC.*$'/'\1'/g`;do
    # Ignore any object with _VGIGNOREVG_ in the name.
    echo $f
    if echo "$f" | grep -q _VGIGNOREVG_; then
      echo "  Ignoring"
      i=$((i+1))
      continue
    fi
    for y in obj mtl png;do
      echo "  export/$file-$i.$y --> output/$f.$y"
      mkdir -p $(dirname output/$f.y)
      cp export/$file-$i.$y output/$f.$y
    done
    b=$(basename $f)
    sed -i -- s/"$file-$i"/"$b"/g output/$f.obj
    sed -i -- 's/\r$//' output/$f.obj
    sed -i -- s/"$file-$i"/"$b"/g output/$f.mtl
    sed -i -- 's/\r$//' output/$f.mtl
    sed -i -- 's/illum 1/illum 1/g' output/$f.mtl
    sed -i -- 's/Ka 0.000 0.000 0.000/Ka 1.000 1.000 1.000/g' output/$f.mtl
    sed -i -- 's/Kd 1.000 1.000 1.000/Kd 1.000 1.000 1.000/g' output/$f.mtl
    sed -i -- 's/Ks 0.000 0.000 0.000/Ks 0.000 0.000 0.000/g' output/$f.mtl
    grep -q output/$f.mtl -e "^Ns 200$" || echo "Ns 200" >> output/$f.mtl
    grep -q output/$f.mtl -e "^d 1$" || echo "d 1" >> output/$f.mtl
    i=$((i+1))
  done
done
echo "All done!"
