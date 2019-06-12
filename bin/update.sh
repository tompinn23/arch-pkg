#! /bin/bash

for pkg in $(auracle --color=never sync | sed 's/\s.*$//')
do
	auracle -r download $pkg
done
