#!/bin/bash
echo $(pwd)
echo "Generating .SRCINFO"
find -name PKGBUILD -execdir sh -c 'makepkg --printsrcinfo > .SRCINFO' \;

