# plex-build-debian-sysvinit
Build the Plex .deb packages for sysvinit system

This script follows the instructions from [Ryushin](https://forums.plex.tv/profile/discussions/Ryushin).

Link of the thread: https://forums.plex.tv/discussion/51427/plex-media-server-for-debian/p49

### Instructions to build
---

#### With NodeJS
---

Prerequisites:

- A Unix system which can run all the commands in the script
- npm

And then:

1. Go to the **nodejs** directory: **cd nodejs**
2. Install needed libraries: **npm i**
3. Run the script: **node index.js**

#### With shellscript
---

1. Go to the **shellscript** directory: **cd shellscript**
2. Make the script executable: **chmod +x build-packages.sh**
3. Run the script: **./build-packages.sh**


**At the end, you should get the .deb file in your working directory.**