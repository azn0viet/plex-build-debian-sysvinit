#!/bin/bash

stop_script_if_last_command_has_failed() {
	if [ $1 -ne 0 ]; then exit 1; fi
}

stop_script_and_display_error_if_empty() {
	if [ ! "$1" ]; then
		if [ "$2" ]; then 
			echo "Error: $2"
		else
			echo "Error: no explicit message"
		fi
		exit 1
	fi
}

build_debian_package() {
	if [ "$1" != "amd64" -a "$1" != "i386" ]; then
		echo "The parameter should be either amd64 or i386."
		return
	fi

	# JSON_STRING=$(curl -s "https://plex.tv/api/downloads/1.json")
	JSON_STRING=$(curl -s "https://plex.tv/pms/downloads/5.json")
	BASE_DIR="$1_base"

	# Get the download URL (first .deb url field)
	# echo $JSON_STRING
	URL=$(echo $JSON_STRING | grep -Po '"url":.*?[^\\]"' | sed 's/"url":"//g' | sed 's/"//g' | grep '\.deb$' | grep $1 | head -n1)
	stop_script_and_display_error_if_empty "$URL" "Cannot find the URL"

	# Set  file name (last item splitted by /)
	FILENAME=$(echo $URL | rev | cut -d'/' -f 1 | rev)
	stop_script_and_display_error_if_empty "$FILENAME" "Cannot set the filename"

	# Set the version
	VERSION=$(echo $FILENAME | sed 's/plexmediaserver_//g' | sed "s/_$1.deb//g")
	stop_script_and_display_error_if_empty "$VERSION" "Cannot set the version"

	# Set the final file name
	FINAL_FILE_NAME="plexmediaserver_$VERSION-sysvinit_$1.deb"
	stop_script_and_display_error_if_empty "$FINAL_FILE_NAME" "Cannot set the final filename"

	# Set the directory where the debian package is unpacked
	DIRECTORY=$(echo $FILENAME | sed 's/.deb//g')
	stop_script_and_display_error_if_empty "$DIRECTORY" "Cannot set the directory"

	# Set the tmp directory
	TMP="tmp_plex_$1"

	# Remove the tmp/ directory if exists
	if [ -d $TMP ]; then rm -rf $TMP; fi

	# Download the file
	wget $URL -P $TMP
	stop_script_if_last_command_has_failed $?

	# Unpack the debian package
	dpkg -x $TMP/$FILENAME $TMP/$DIRECTORY
	stop_script_if_last_command_has_failed $?

	# Untar the "prepared folder"
	tar xvf $BASE_DIR.tar.xz -C $TMP
	stop_script_if_last_command_has_failed $?

	# Move usr/ directory
	mv $TMP/$DIRECTORY/usr $TMP/$BASE_DIR/debian
	stop_script_if_last_command_has_failed $?

	# Change the version in the amd64-or-i386_base/debian/DEBIAN/control file
	sed -i "/Version/c\Version: $VERSION-debian" $TMP/$BASE_DIR/debian/DEBIAN/control
	stop_script_if_last_command_has_failed $?

	# Repack the debian package
	dpkg-deb --build $TMP/$BASE_DIR/debian
	stop_script_if_last_command_has_failed $?

	# Move and rename the debian.deb built
	mv $TMP/$BASE_DIR/debian.deb $FINAL_FILE_NAME
	stop_script_if_last_command_has_failed $?

	# Remove the tmp/ directory
	rm -rf $TMP
	stop_script_if_last_command_has_failed $?

	echo
	echo "SUCCESS"
	ls -l | grep $FINAL_FILE_NAME
	echo
}

build_debian_package amd64
build_debian_package i386
