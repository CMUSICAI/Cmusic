
Debian
====================
This directory contains files used to package cmusicaid/cmusicai-qt
for Debian-based Linux systems. If you compile cmusicaid/cmusicai-qt yourself, there are some useful files here.

## cmusicai: URI support ##


cmusicai-qt.desktop  (Gnome / Open Desktop)
To install:

	sudo desktop-file-install cmusicai-qt.desktop
	sudo update-desktop-database

If you build yourself, you will either need to modify the paths in
the .desktop file or copy or symlink your cmusicai-qt binary to `/usr/bin`
and the `../../share/pixmaps/cmusicai128.png` to `/usr/share/pixmaps`

cmusicai-qt.protocol (KDE)

