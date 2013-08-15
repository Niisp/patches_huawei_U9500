#!/bin/bash
cd `dirname $0`
DSTDIR=$1

if [ -z "$DSTDIR" ]
then
    echo "Usage: $0 <sources dir>"
    exit 1
fi

# back port bluez
echo ""
echo "Back porting bluez"

DISTR=`head -1 $DSTDIR/.repo/manifests/README.*`

case "$DISTR" in
  "CyanogenMod")
    echo "---=== CyanogenMod ===---"
    bluez_port_cm101/cm101_bluez_patch.sh $DSTDIR
    ;;
  "MoKee OpenSource")
    echo "---=== MoKee OpenSource ===---"
    bluez_port_cm101/cm101_bluez_patch.sh $DSTDIR
    ;;
  "PAC-man - The AIO ROM")
    echo "---=== PAC-man - The AIO ROM ===---"
    bluez_port_pac/pac_bluez_patch.sh $DSTDIR
    ;;
  *)
    echo "*================== Error!!! =================*"
    echo "| Who is here? I do not know what the system |"
    echo "*============================================*"
    exit 1
  ;;
esac

# AudioRecord patch
echo ""
echo "Applying AudioRecord patch"
cat allpatches/AudioRecord.patch | patch -d $DSTDIR/frameworks/av/ -p1 -N -r -

# Adding caller geo info database
echo ""
echo "Adding CallerGeoInfo data"
cp allpatches/geoloc/86_zh $DSTDIR/external/libphonenumber/java/src/com/android/i18n/phonenumbers/geocoding/data/86_zh
cp allpatches/geoloc/PhoneNumberMetadataProto_CN $DSTDIR/external/libphonenumber/java/src/com/android/i18n/phonenumbers/data/PhoneNumberMetadataProto_CN

# EMUI Gallery/Camera patch
echo ""
echo "Applying EMUI Gallery/Camera patch"
cat allpatches/EMUI_Gallery2.patch | patch -d $DSTDIR/frameworks/base -p1 -N -r -

# Camera patch
echo ""
echo "Applying Camera patch"
cat allpatches/Camera.patch | patch -d $DSTDIR/packages/apps/Camera -p1 -N -r -

# SurfaceFlinger patch
echo ""
echo "Applying SurfaceFlinger patch"
cat allpatches/SurfaceFlinger.patch | patch -d $DSTDIR/frameworks/native -p1 -N -r -

# if not removed - there will be errors
echo ""
echo "Remove *.orig files"
rm -f $DSTDIR/frameworks/base/core/res/res/values/*.orig

echo "Done"
