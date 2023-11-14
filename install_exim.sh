#!/bin/bash

MYROOT="$PWD"
OPTDIR="/opt/exim4/"

if [ $UID != 0 ]; then
	echo "Must run as 'root', or with 'sudo'"
	exit
fi

if [ -z $1 ]; then
	echo "Please provide release number as argument."
	exit
else
	INSTVER=$1
fi

DPKG=$(dpkg -l)

echo "Checking package dependencies..."
for dep in `cat required.apt`; do
	if grep -q "ii $dep" <<< $(echo $DPKG); then
		echo "$dep is already installed"
	else
		echo "Installing $dep..."
		DEBIAN_FRONTEND=noninteractive apt-get --assume-yes install $dep 2>/dev/null >/dev/null
	fi
done

echo "Creating users and groups..."
USER=`id -u mailcleaner 2>/dev/null`
if [ $? ]; then
	useradd mailcleaner --system --create-home --user-group --home-dir /var/mailcleaner --shell /usr/sbin/nologin 2>/dev/null
fi

echo "Checking Exim Git source..."
if [ ! -e "${MYROOT}/exim" ]; then
	echo "Cloning Exim Git..."
	git clone https://github.com/exim/exim.git --depth 1 2>&1 >/dev/null
	git fetch --tags 2>&1 >/dev/null
	cd ${MYROOT}/exim
else
	echo "Pulling Exim Git..."
	cd ${MYROOT}/exim
	git pull 2>&1 >/dev/null
	git fetch --tags 2>&1 >/dev/null
fi
echo "Checking out tag exim-${INSTVER}..."
git checkout exim-${INSTVER}


echo "Setting up Build directory..."
cd $MYROOT
rm -rf exim-${INSTVER}
cp -r exim/src exim-${INSTVER}

echo "Loading Libraries..."
ldconfig 2>&1

echo "Building Exim..."
cd ${MYROOT}/exim-${INSTVER}
mkdir Local
cp ../DEBIAN/EDITME Local/Makefile
EXIM_RELEASE_VERSION=${INSTVER} make -j6 2>&1
make install 2>&1

echo "Building .deb"
cd $MYROOT

if [ -d ../mc-exim-${INSTVER} ]; then
	rm -rf ../mc-exim-${INSTVER}
fi
cp -r mc-exim mc-exim-${INSTVER}
cp -r DEBIAN mc-exim-${INSTVER}/
mkdir -p mc-exim-${INSTVER}${OPTDIR}
cp -a ${OPTDIR}/* mc-exim-${INSTVER}${OPTDIR}/

sed -i 's/__INSTVER__/'$INSTVER'/' mc-exim-${INSTVER}/DEBIAN/control
sed -i 's/__INSTSIZE__/'$(du -sk mc-exim-${INSTVER} | cut -f1)'/' mc-exim-${INSTVER}/DEBIAN/control
dpkg-deb -b -Z xz mc-exim-${INSTVER} mc-exim-${INSTVER}_amd64.deb

echo ".deb created at: $MYROOT/mc-exim-${INSTVER}_amd64.deb"
