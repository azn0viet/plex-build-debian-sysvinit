#!/bin/bash

build_debian_package() {
	if [ "$1" != "amd64" -a "$1" != "i386" ]; then
		echo "The parameter should be either amd64 or i386."
		return
	fi

	DEFAULT_VERSION_IN_CONTROL_FILE="1.9.5.4339-46276db8d"
	JSON_STRING=$(curl -s "https://plex.tv/api/downloads/1.json")
	BASE_DIR="$1_base"

	# Get the download URL (first .deb url field)
	URL=$(echo $JSON_STRING | grep -Po '"url":.*?[^\\]"' | sed 's/"url":"//g' | sed 's/"//g' | grep '\.deb$' | grep $1 | head -n1)

	# Set  file name (last item splitted by /)
	FILENAME=$(echo $URL | rev | cut -d'/' -f 1 | rev)

	# Set the version
	VERSION=$(echo $FILENAME | sed 's/plexmediaserver_//g' | sed "s/_$1.deb//g")

	# Set the final file name
	FINAL_FILE_NAME="plexmediaserver_$VERSION-sysvinit_$1.deb"

	# Set the directory where the debian package is unpacked
	DIRECTORY=$(echo $FILENAME | sed 's/.deb//g')

	# Set the tmp directory
	TMP="tmp_plex_$1"

	# Remove the tmp/ directory if exists
	if [ -d $TMP ]; then
		rm -rf $TMP
	fi

	# Download the file
	wget $URL -P $TMP

	# Unpack the debian package
	dpkg -x $TMP/$FILENAME $TMP/$DIRECTORY

	# Untar the "prepared folder"
	tar xvf $BASE_DIR.tar.xz -C $TMP

	# Move usr/ directory
	mv $TMP/$DIRECTORY/usr $TMP/$BASE_DIR/debian

	# Change the version in the amd64-or-i386_base/debian/DEBIAN/control file
	sed -i "/Version/c\Version: $VERSION-debian" $TMP/$BASE_DIR/debian/DEBIAN/control

	# Repack the debian package
	dpkg-deb --build $TMP/$BASE_DIR/debian

	# Move and rename the debian.deb built
	mv $TMP/$BASE_DIR/debian.deb $FINAL_FILE_NAME

	# Remove the tmp/ directory
	rm -rf $TMP

	echo
	echo "SUCCESS"
	ls -l | grep $FINAL_FILE_NAME
	echo
}

build_debian_package amd64
build_debian_package i386
