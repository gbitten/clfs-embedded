#!/bin/bash
# Create a uClibc Patch

# Get Version #
#
VERSION=$1

# Check Input
#
if [ "${VERSION}" = "" ]; then
  echo "$0 - uClibc_Version"
  echo "This will Create a Patch for uClibc uClibc_Version"
  exit 255
fi

# Download uClibc Source
#
cd /usr/src
if ! [ -e uClibc-${VERSION}.tar.bz2  ]; then
  wget http://www.uclibc.org/downloads/uClibc-${VERSION}.tar.bz2
fi

# Set Patch Number
#
cd /usr/src
wget http://svn.cross-lfs.org/svn/repos/cross-lfs/branches/clfs-embedded/patches/ --no-remove-listing
PATCH_NUM=$(cat index.html | grep uClibc | grep "${VERSION}" | grep branch_update | cut -f2 -d'"' | cut -f1 -d'"'| cut -f4 -d- | cut -f1 -d. | tail -n 1)
PATCH_NUM=$(expr ${PATCH_NUM} + 1)
rm -f index.html

# Cleanup Directory
#
rm -rf uClibc-${VERSION} uClibc-${VERSION}.orig
tar xvf uClibc-${VERSION}.tar.bz2
mv uClibc-${VERSION} uClibc-${VERSION}.orig
CURRENTDIR=$(pwd -P)

# Get Current Updates from SVN
#
cd /usr/src
FIXEDVERSION=$(echo ${VERSION} | sed -e 's/\./_/g')
svn export  svn://uclibc.org/branches/uClibc_${FIXEDVERSION} uClibc-${VERSION}

# Create Patch
#
cd /usr/src
echo "Submitted By: Jim Gifford (jim at cross-lfs dot org)" > uClibc-${VERSION}-branch_update-${PATCH_NUM}.patch
echo "Date: `date +%m-%d-%Y`" >> uClibc-${VERSION}-branch_update-${PATCH_NUM}.patch
echo "Initial Package Version: ${VERSION}" >> uClibc-${VERSION}-branch_update-${PATCH_NUM}.patch
echo "Origin: Upstream" >> uClibc-${VERSION}-branch_update-${PATCH_NUM}.patch
echo "Upstream Status: Applied" >> uClibc-${VERSION}-branch_update-${PATCH_NUM}.patch
echo "Description: This is a branch update for uClibc-${VERSION}, and should be" >> uClibc-${VERSION}-branch_update-${PATCH_NUM}.patch
echo "             rechecked periodically." >> uClibc-${VERSION}-branch_update-${PATCH_NUM}.patch
echo "" >> uClibc-${VERSION}-branch_update-${PATCH_NUM}.patch
diff -Naur uClibc-${VERSION}.orig uClibc-${VERSION} >> uClibc-${VERSION}-branch_update-${PATCH_NUM}.patch
echo "Created /usr/src/uClibc-${VERSION}-branch_update-${PATCH_NUM}.patch."
