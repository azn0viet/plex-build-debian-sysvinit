#!/bin/bash

build_debian_package amd64_base
# build_debian_package i386

build_debian_package() {
	DEFAULT_VERSION_IN_CONTROL_FILE="1.9.5.4339-46276db8d"
	JSON_STRING=$(curl -s "https://plex.tv/api/downloads/1.json")

	# Get the download URL (first .deb url field)
	URL=$(echo $JSON_STRING | grep -Po '"url":.*?[^\\]"' | sed 's/"url":"//g' | sed 's/"//g' | grep '\.deb$' | head -n 1)

	# Set  file name (last item splitted by /)
	FILENAME=$(echo $URL | rev | cut -d'/' -f 1 | rev)

	# Set the version
	VERSION=$(echo $FILENAME | sed 's/plexmediaserver_//g' | sed 's/_amd64.deb//g')

	# Set the final file name
	FINAL_FILE_NAME="plexmediaserver_$VERSION-sysvinit_amd64.deb"

	# Set the directory where the debian package is unpacked
	DIRECTORY=$(echo $FILENAME | sed 's/.deb//g')

	# Set the tmp directory
	TMP="tmp_plex"

	# Remove the tmp/ directory if exists
	if [ -d $TMP ]; then
		rm -rf $TMP
	fi

	# Download the file
	wget $URL -P $TMP

	# Unpack the debian package
	dpkg -x $TMP/$FILENAME $TMP/$DIRECTORY

	# Untar the "prepared folder"
	tar xvf amd64_base.tar.xz -C $TMP

	# Move usr/ directory
	mv $TMP/$DIRECTORY/usr $TMP/amd64_base/debian

	# Change the version in the amd64_base/debian/DEBIAN/control file
	sed -i.bak s/$DEFAULT_VERSION_IN_CONTROL_FILE/$VERSION/g $TMP/amd64_base/debian/DEBIAN/control

	# Repack the debian package
	dpkg-deb --build $TMP/amd64_base/debian

	# Move and rename the debian.deb built
	mv $TMP/amd64_base/debian.deb $FINAL_FILE_NAME

	# Remove the tmp/ directory
	rm -rf $TMP

	echo
	echo "SUCCESS"
	ls -l | grep $FINAL_FILE_NAME
	echo
}

