# VoxObjRename script

Copyright (c) 2019, Luis Quesada Torres - https://github.com/lquesada | www.luisquesada.com

This script takes as input a set of MagicaVoxel vox files and a set of
exported .obj/.mtl/.png files, and creates copies of the .obj/.mtl/.png files
named after the objects. MagicaVoxel defaults to exporting with names such as
"test-1.obj", "test-1.mtl", "test-1.png", "test-2.obj", "test-2.mtl", etc.

The "MagicaVoxel-0.99.2" directory contains the required version of
MagicaVoxel.

The "vox" and "export" directories contain an example valid input.

# Disclaimer
This is a very hacky script.

It is quite flaky and it works based on assumptioms.

Use at your own risk.

Before using, please read and understand the [LICENSE](LICENSE) file.

# How to use

Prepare the input like this:

- a "vox" subdirectory that contains one or more MagicaVoxel .vox files

  ALL object names must start and end with "_VGCX_"

  For example, valid names are: "_VGCX_dog_VGCX_" or "_VGCX_animal/dog_VGCX_"
  Please note that the name can contain "/" to specify subdirectories.

  Objects with _VGIGNORE_ in the name will be ignored. Please note that the
  object names must still start and end with _VGCX_.

  For example, object "_VGCX__VGIGNORE_placeholder_VGCX_" will be ignored

- an "export" subdirectory that contains all the exported .obj/.mtl/.png
  files for all the vox files above

  These files must be exported using MagicaVoxel 0.99.2. Later versions alter
  the center coordinates to maintain the scene in one piece, but we do want
  to export all models centered

  A common source of flakiness is to have more or less .obj/.mtl/.png files
  than objects are in the .vox files, so double check if something goes wrong

Run the script like this: $ bash voxobjrename.sh

The script will process the "vox" and "export" subdirectories
non-destructively and generate an "output" directory where .obj/.mtl/.png
files have the proper name, e.g. "dog.obj", "dog.mtl", "dog.png".

The script also edits some values in the mtl files so that the texture is
imported correctly from some software. Feel free to tweak or remove the
overrides if they don't work for you.
