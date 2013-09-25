#!/bin/bash
SRCDIR=`dirname $0`
DSTDIR=$1
NEWPATCH=1


if [ -z "$DSTDIR" ]
then
    echo "Usage: $0 <sources dir>"
    exit 1
fi

grn=$(tput setaf 2) # Green
ylw=$(tput setaf 3) # Yellow
txtrst=$(tput sgr0) # Reset

#My
rm -f $DSTDIR/frameworks/base/core/jni/android_server_BluetoothEventLoop.cpp

# build/core/pathmap.mk: patch
echo "${ylw}[build/core] Patch pathmap.mk${txtrst}"
cat $SRCDIR/patches/build_core.patch | patch -d $DSTDIR/build/core -p0 -N -r -


# external/bluetooth: 1. remove bluedroid
#                     2. copy bluez, glib and hcidump
echo "${ylw}[external/bluetooth] removing mk files from bluedroid${txtrst}"
rm -f $DSTDIR/external/bluetooth/bluedroid/Android.mk
rm -f $DSTDIR/external/bluetooth/bluedroid/audio_a2dp_hw/Android.mk
echo "${ylw}[external/bluetooth] adding bluez, glib and hcidump${txtrst}"
cp -r bluez_all/external/bluetooth/* $DSTDIR/external/bluetooth/


# packages/apps: 1. replace Bluetooth; 
#                2. patch Phone
echo "${ylw}[packages/apps] removing Bluetooth${txtrst}"
rm -rf $DSTDIR/packages/apps/Bluetooth

echo "${ylw}[packages/apps] adding Bluetooth${txtrst}"
cp -r bluez_all/packages/apps/Bluetooth $DSTDIR/packages/apps/

echo ""
echo "${ylw}[packages/apps] patching Phone${txtrst}"
cat $SRCDIR/patches/Phone_all2.patch | patch -d $DSTDIR/packages/apps/Phone -p1 -N -r -


if [ "$NEWPATCH" = "1" ]
then
    echo ""
    echo "${ylw}[frameworks/base] applying patch frameworks_base_all2.patch${txtrst}"
    cat $SRCDIR/patches/frameworks_base_all2.patch | patch -d $DSTDIR/frameworks/base -p1 -N -r -
else
# frameworks/base:
#           1. merge core/java/android/bluetooth/
#           2. merge core/java/android/server/
#           3. merge core/jni/
#           4. merge core/res/res/values/
#           5. remove services/java/com/android/server/BluetoothManagerService.java
#           6. apply patch frameworks_base.patch
#                   Android.mk
#                   core/java/com/android/internal/util/StateMachine.java
#                   core/jni/Android.mk
#                   core/jni/AndroidRuntime.cpp
#                   core/res/res/values/config.xml
#                   core/res/res/values/symbols.xml
#                   services/java/com/android/server/NetworkManagementService.java
#                   services/java/com/android/server/power/ShutdownThread.java
#                   services/java/com/android/server/SystemServer.java

    echo "${ylw}[frameworks/base] merging core${txtrst}"
    cp -r bluez_all/frameworks/base/core $DSTDIR/frameworks/base/
    echo "${ylw}[frameworks/base] removing services/java/com/android/server/BluetoothManagerService.java${txtrst}"
    rm -f $DSTDIR/frameworks/base/services/java/com/android/server/BluetoothManagerService.java
    echo "${ylw}[frameworks/base] applying patch frameworks_base.patch${txtrst}"
    cat $SRCDIR/patches/frameworks_base.patch | patch -d $DSTDIR/frameworks/base -p0 -N -r -
fi

echo "${grn}Done${txtrst}"
