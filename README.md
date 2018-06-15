# plex-build-debian-sysvinit
Build the Plex .deb packages for sysvinit system

This script follows the instructions from [Ryushin](https://forums.plex.tv/profile/discussions/Ryushin).

Link of the thread: https://forums.plex.tv/discussion/51427/plex-media-server-for-debian/p49

### Instructions to build

Prerequisites:

- A Unix system which can run all the commands in the script
- npm

And then:

1. Clone this repository
2. Install needed libraries by running the command:	`npm i`
3. Run the script by running the command: `node index.js`

At the end, you should get the .deb file in your working directory.