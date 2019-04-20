#!/bin/bash


INFOLOG="$(tput bold; tput setaf 7)[$(tput setaf 2)INFO$(tput setaf 7)]$(tput sgr0)"
WARNINGLOG="$(tput bold; tput setaf 7)[$(tput setaf 3)WARNING$(tput setaf 7)]$(tput sgr0)"

for dir in */;
do
	cd $dir
	if [ -f "PKGBUILD" ]; then
	echo -e "${INFOLOG} Generating SRCINFO: ${dir%/}"
	sh -c 'makepkg --printsrcinfo > .SRCINFO'
	fi
	cd ..
done


REPODIR=${1:-$(pwd)}
PASSWORD=$2
for pkg in $(aur graph */.SRCINFO | tsort | tac) 
do
	cd $pkg
	echo -e "${INFOLOG} Building ${pkg}"
	if [ -f "PKGBUILD.old" ]; then
		shaOld=$(sha256sum -z PKGBUILD.old | awk '{ print $1 }')
		shaNew=$(sha256sum -z PKGBUILD | awk '{ print $1 }')
		found_pkg=($(find -iname '*.pkg.tar.xz'))
		if [ $shaOld == $shaNew ] && [ ${#found_pkg} -gt 0 ]; then
			echo -e "${WARNINGLOG} Package: \"${pkg}\" has not changed not building.\n"
			cd ..
			continue
		fi
	fi
	makepkg --force --noconfirm --syncdeps
	for package_file in $(find -name '*.pkg.tar.xz' -printf "%f\n") 
	do
		echo "${INFOLOG} Signing package file: ${package_file}"
		echo $PASSWORD | gpg --batch --pinentry-mode=loopback --passphrase-fd=0 --detach-sign --use-agent --no-armor --yes "$package_file"
	done
	repo-add -R $REPODIR/repo/c0dd.db.tar $(find -name '*.pkg.tar.xz' -printf "%f\n")
	cp $(find -name '*.pkg.tar.xz' -printf "%f\n") $REPODIR/repo/
	cp $(find -name '*.sig' -printf "%f\n") $REPODIR/repo/
	cp PKGBUILD PKGBUILD.old
	cd ..
done
echo $PASSWORD | gpg --batch --pinentry-mode=loopback --passphrase-fd=0 --detach-sign --use-agent --no-armor --yes $REPODIR/repo/c0dd.db.tar
echo $PASSWORD | gpg --batch --pinentry-mode=loopback --passphrase-fd=0 --detach-sign --use-agent --no-armor --yes $REPODIR/repo/c0dd.db
echo $PASSWORD | gpg --batch --pinentry-mode=loopback --passphrase-fd=0 --detach-sign --use-agent --no-armor --yes $REPODIR/repo/c0dd.files
rm $REPODIR/repo/*.old
