VERSION=1.0.2.0
rm -rf ./release-linux
mkdir release-linux

cp ./src/cmusicaid ./release-linux/
cp ./src/cmusicai-cli ./release-linux/
cp ./src/qt/cmusicai-qt ./release-linux/
cp ./CMUSICAICOIN_small.png ./release-linux/

cd ./release-linux/
strip cmusicaid
strip cmusicai-cli
strip cmusicai-qt

#==========================================================
# prepare for packaging deb file.

mkdir cmusicaicoin-$VERSION
cd cmusicaicoin-$VERSION
mkdir -p DEBIAN
echo 'Package: cmusicaicoin
Version: '$VERSION'
Section: base 
Priority: optional 
Architecture: all 
Depends:
Maintainer: CmusicAI
Description: CmusicAI coin wallet and service.
' > ./DEBIAN/control
mkdir -p ./usr/local/bin/
cp ../cmusicaid ./usr/local/bin/
cp ../cmusicai-cli ./usr/local/bin/
cp ../cmusicai-qt ./usr/local/bin/

# prepare for desktop shortcut
mkdir -p ./usr/share/icons/
cp ../CMUSICAICOIN_small.png ./usr/share/icons/
mkdir -p ./usr/share/applications/
echo '
#!/usr/bin/env xdg-open

[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Exec=/usr/local/bin/cmusicai-qt
Name=cmusicaicoin
Comment= cmusicai coin wallet
Icon=/usr/share/icons/CMUSICAICOIN_small.png
' > ./usr/share/applications/cmusicaicoin.desktop

cd ../
# build deb file.
dpkg-deb --build cmusicaicoin-$VERSION

#==========================================================
# build rpm package
rm -rf ~/rpmbuild/
mkdir -p ~/rpmbuild/{RPMS,SRPMS,BUILD,SOURCES,SPECS,tmp}

cat <<EOF >~/.rpmmacros
%_topdir   %(echo $HOME)/rpmbuild
%_tmppath  %{_topdir}/tmp
EOF

#prepare for build rpm package.
rm -rf cmusicaicoin-$VERSION
mkdir cmusicaicoin-$VERSION
cd cmusicaicoin-$VERSION

mkdir -p ./usr/bin/
cp ../cmusicaid ./usr/bin/
cp ../cmusicai-cli ./usr/bin/
cp ../cmusicai-qt ./usr/bin/

# prepare for desktop shortcut
mkdir -p ./usr/share/icons/
cp ../CMUSICAICOIN_small.png ./usr/share/icons/
mkdir -p ./usr/share/applications/
echo '
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Exec=/usr/bin/cmusicai-qt
Name=cmusicaicoin
Comment= cmusicai coin wallet
Icon=/usr/share/icons/CMUSICAICOIN_small.png
' > ./usr/share/applications/cmusicaicoin.desktop
cd ../

# make tar ball to source folder.
tar -zcvf cmusicaicoin-$VERSION.tar.gz ./cmusicaicoin-$VERSION
cp cmusicaicoin-$VERSION.tar.gz ~/rpmbuild/SOURCES/

# build rpm package.
cd ~/rpmbuild

cat <<EOF > SPECS/cmusicaicoin.spec
# Don't try fancy stuff like debuginfo, which is useless on binary-only
# packages. Don't strip binary too
# Be sure buildpolicy set to do nothing

Summary: CmusicAI wallet rpm package
Name: cmusicaicoin
Version: $VERSION
Release: 1
License: MIT
SOURCE0 : %{name}-%{version}.tar.gz
URL: https://www.cmusicaicoin.net/

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

%description
%{summary}

%prep
%setup -q

%build
# Empty section.

%install
rm -rf %{buildroot}
mkdir -p  %{buildroot}

# in builddir
cp -a * %{buildroot}


%clean
rm -rf %{buildroot}


%files
/usr/share/applications/cmusicaicoin.desktop
/usr/share/icons/CMUSICAICOIN_small.png
%defattr(-,root,root,-)
%{_bindir}/*

%changelog
* Tue Aug 24 2021  CmusicAI Project Team.
- First Build

EOF

rpmbuild -ba SPECS/cmusicaicoin.spec



