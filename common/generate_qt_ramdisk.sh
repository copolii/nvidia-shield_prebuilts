#!/bin/bash
#
# Copyright (c) 2012-2013 NVIDIA Corporation.  All rights reserved.
#
# NVIDIA Corporation and its licensors retain all intellectual property
# and proprietary rights in and to this software, related documentation
# and any modifications thereto.  Any use, reproduction, disclosure or
# distribution of this software and related documentation without an express
# license agreement from NVIDIA Corporation is strictly prohibited.
#
# Usage: generate_qt_ramdisk.sh [target_board] [debug|release]
#        generate_qt_ramdisk.sh --help
#
# Description: Generate a ramdisk image suitable for minimal booting of
#              systems without an root file system (such as early development
#              FPGAs systems).
#
# WARNING:  Loading up the ramdisk lots of extraneous files will severely
#           impact the boot time on FPGA systems. The files copied by this
#           script should be kept to the smallest subset possible.
#-------------------------------------------------------------------------------

# Give 'em help if they asked for it.
if [ "$1" == "--help" ]; then
    this_script=`basename $0`
    echo " "
    echo "Generate an Android ramdisk image capable of booting without"
    echo "an external file system."
    echo " "
    echo "Usage:"
    echo " "
    echo "  $this_script [target_board] [build_flavor]"
    echo "  $this_script --help"
    echo " "
    echo "where:"
    echo " "
    echo "  target_board: aruba2 | cardhu | kai   (default is aruba2)"
    echo "  build_flavor: debug | release   (default is debug)"
    echo "  --help:       produces this description"
    echo " "
    exit 0
fi

# Sanity checks & default option processing
if [ "$TOP" == "" ]; then
    echo "ERROR: You must set environment variable TOP to the top of your nvrepo tree"
    exit 2
fi

if [ "$TOP" == "." ]; then
    top=`pwd`
else
    top=$TOP
fi

if [ "$1" == "" ]; then
    echo "Assuming target board is aruba2"
    target_board="aruba2"
else
    target_board=$1
fi

if [ "$2" == "" ]; then
    echo "Assuming build flavor is debug"
    build_flavor="debug"
else
    build_flavor=$2
fi

if [ "$build_flavor" == "debug" ]; then
    product_dir=$top/out/debug/target/product/$target_board
elif [ "$build_flavor" == "release" ]; then
    product_dir=$top/out/target/product/$target_board
else
    echo "ERROR: Invalid build flavor -- must be debug or release"
    exit 2
fi

# Host tools directory
android_host_bin=$top/out/host/linux-x86/bin

if [ -d "$product_dir" ]; then
    echo "Using $product_dir/qt_ramdisk_tmpdir to build new ramdisk contents"
    rm -rf $product_dir/qt_ramdisk_tmpdir
    mkdir -p $product_dir/qt_ramdisk_tmpdir
else
    echo "ERROR: Product output directory $product_dir does not exist"
    exit 2
fi

# Extract the contents of standard ramdisk image generated by JackBuild
if [ -f "$product_dir/ramdisk.img" ]; then
    echo "Unpacking archive $product_dir/ramdisk.img"
    cd $product_dir/qt_ramdisk_tmpdir
    gzip -dc < $product_dir/ramdisk.img | cpio --extract
else
    echo "ERROR: No ramdisk.img found in $product_dir"
    exit 2
fi

#echo "Adding files to $product_dir/qt_ramdisk_tmpdir/sbin"
#mkdir -p $product_dir/qt_ramdisk_tmpdir/sbin
#cd $product_dir/qt_ramdisk_tmpdir/sbin
#cp $product_dir/system/bin/nvtest .
#chmod +x ./nvtest

echo "Adding files to $product_dir/qt_ramdisk_tmpdir/system"
mkdir -p $product_dir/qt_ramdisk_tmpdir/system
cd $product_dir/qt_ramdisk_tmpdir/system
cp $product_dir/system/build.prop .

echo "Adding files to $product_dir/qt_ramdisk_tmpdir/system/bin"
mkdir -p $product_dir/qt_ramdisk_tmpdir/system/bin
cd $product_dir/qt_ramdisk_tmpdir/system/bin
cp $product_dir/system/bin/toolbox .
#cp $product_dir/system/bin/app_process .
#cp $product_dir/system/bin/avp_load .

#cp $product_dir/system/bin/debuggerd .
#cp $product_dir/system/bin/gdbserver .
#cp $product_dir/system/bin/ifconfig .
#cp $product_dir/system/bin/iftop .
#cp $product_dir/system/bin/keystore .
#cp $product_dir/system/bin/keystore_cli .
cp $product_dir/system/bin/linker .
cp $product_dir/system/bin/logcat .
cp $product_dir/system/bin/logwrapper .
#cp $product_dir/system/bin/mediaserver .
#cp $product_dir/system/bin/netstat .
#cp $product_dir/system/bin/newfs_msdos .
#cp $product_dir/system/bin/reboot .
#cp $product_dir/system/bin/route .
#cp $product_dir/system/bin/service .
#cp $product_dir/system/bin/servicemanager .
cp $product_dir/system/bin/sh .
#cp $product_dir/system/bin/surfaceflinger .
cp $product_dir/symbols/system/bin/affinity .

cp -s toolbox cat
cp -s toolbox chmod
cp -s toolbox chown
cp -s toolbox cmp
#cp -s toolbox date
#cp -s toolbox dd
#cp -s toolbox df
cp -s toolbox dmesg
cp -s toolbox getevent
cp -s toolbox getprop
#cp -s toolbox hd
#cp -s toolbox id
cp -s toolbox insmod
cp -s toolbox ioctl
cp -s toolbox kill
cp -s toolbox ln
cp -s toolbox log
cp -s toolbox ls
cp -s toolbox lsmod
cp -s toolbox mkdir
cp -s toolbox mount
cp -s toolbox mv
cp -s toolbox notify
cp -s toolbox printenv
cp -s toolbox ps
#cp -s toolbox renice
cp -s toolbox rm
cp -s toolbox rmdir
cp -s toolbox rmmod
cp -s toolbox schedtop
cp -s toolbox sendevent
cp -s toolbox setconsole
cp -s toolbox setprop
cp -s toolbox sleep
#cp -s toolbox smd
cp -s toolbox start
cp -s toolbox stop
#cp -s toolbox sync
cp -s toolbox top
#cp -s toolbox umount
cp -s toolbox vmstat
cp -s toolbox watchprops
cp -s toolbox wipe

if [ "$include_busybox" == "true" ]; then
    # Replace android sh with busybox
    if [ -d $top/busybox-android/ ]; then
        cp $top/busybox-android/busybox .
        for i in `qemu-arm $top/busybox-android/busybox --list`
        do
           rm -rf $i
           ln -sf busybox $i
        done
    fi
fi

# NVIDIA Test applications
#cp $product_dir/system/bin/nvos_unit .
cp $product_dir/system/bin/nvrm_channel .
#cp $product_dir/system/bin/nvrm_unit .
#cp $product_dir/system/bin/omxplayer2 .

# NVIDIA Test scripts
cp $top/device/nvidia/common/dcc .
chmod +x ./dcc
cp $top/device/nvidia/common/hotplug .
chmod +x ./hotplug
cp $top/device/nvidia/common/cluster .
cp $top/device/nvidia/common/cluster_get.sh .
cp $top/device/nvidia/common/cluster_set.sh .
chmod +x ./cluster
chmod +x ./cluster_get.sh
chmod +x ./cluster_set.sh
cp $top/device/nvidia/common/mount_debugfs.sh .
chmod +x ./mount_debugfs.sh

#echo "Adding files to $product_dir/qt_ramdisk_tmpdir/system/etc"
#mkdir -p $product_dir/qt_ramdisk_tmpdir/system/etc
#cd $product_dir/qt_ramdisk_tmpdir/system/etc
#cp $product_dir/system/etc/apns-conf.xml .
#cp $product_dir/system/etc/dbus.conf .
#cp $product_dir/system/etc/hosts .
#cp $product_dir/system/etc/init.goldfish.sh .

#echo "Adding files to $product_dir/qt_ramdisk_tmpdir/system/etc/firmware"
#mkdir -p $product_dir/qt_ramdisk_tmpdir/system/etc/firmware
#cd $product_dir/qt_ramdisk_tmpdir/system/etc/firmware
#cp $product_dir/system/etc/firmware/nvddk_audiofx_core.axf .
#cp $product_dir/system/etc/firmware/nvddk_audiofx_transport.axf .
#cp $product_dir/system/etc/firmware/nvmm_manager.axf .
#cp $product_dir/system/etc/firmware/nvmm_audiomixer.axf .

#echo "Adding files to $product_dir/qt_ramdisk_tmpdir/system/etc/security"
#mkdir -p $product_dir/qt_ramdisk_tmpdir/system/etc
#cd $product_dir/qt_ramdisk_tmpdir/system/etc/security/etc
#cp $product_dir/system/etc/security/otacerts.zip .

echo "Adding files to $product_dir/qt_ramdisk_tmpdir/system/lib"
mkdir -p $product_dir/qt_ramdisk_tmpdir/system/lib
cd $product_dir/qt_ramdisk_tmpdir/system/lib
# Standard libraries
cp $product_dir/system/lib/libc_malloc_debug_leak.so .
cp $product_dir/system/lib/libc.so .
cp $product_dir/system/lib/libcutils.so .
cp $product_dir/system/lib/libdl.so .
cp $product_dir/system/lib/liblog.so .
cp $product_dir/system/lib/libm.so .
cp $product_dir/system/lib/libstdc++.so .
cp $product_dir/system/lib/libthread_db.so .
cp $product_dir/system/lib/libutils.so .
cp $product_dir/system/lib/libcorkscrew.so .
cp $product_dir/system/lib/libgccdemangle.so .
cp $product_dir/system/lib/libz.so .
cp $product_dir/system/lib/libselinux.so .
cp $product_dir/system/lib/libnvtestresults.so .
cp $product_dir/system/lib/libnvtestio.so .

# Android libraries
cp $product_dir/system/lib/libbinder.so .
cp $product_dir/system/lib/libhardware.so .
cp $product_dir/system/lib/libhardware_legacy.so .
#cp $product_dir/system/lib/libnetutils.so .
#cp $product_dir/system/lib/libpixelflinger.so .
#cp $product_dir/system/lib/libsurfaceflinger_client.so .
#cp $product_dir/system/lib/libui.so .
#cp $product_dir/system/lib/libwpa_client.so .
cp $product_dir/system/lib/libusbhost.so .

# NVIDIA libraries
#cp $product_dir/system/lib/libcgdrv.so .
#cp $product_dir/system/lib/libEGL.so .
#cp $product_dir/system/lib/libGLESv1_CM.so .
#cp $product_dir/system/lib/libGLESv2.so .
#cp $product_dir/system/lib/libnvddk_2d.so .
#cp $product_dir/system/lib/libnvddk_2d_v2.so .
#cp $product_dir/system/lib/libnvddk_aes_user.so .
#cp $product_dir/system/lib/libnvddk_audiofx.so .
#cp $product_dir/system/lib/libnvddk_audiofx_core.so .
#cp $product_dir/system/lib/libnvdispmgr_d.so .
#cp $product_dir/system/lib/libnvec.so .
#cp $product_dir/system/lib/libnvidia_display_jni.so .
#cp $product_dir/system/lib/libnvmm_audio.so .
#cp $product_dir/system/lib/libnvmm_camera.so .
#cp $product_dir/system/lib/libnvmm_contentpipe.so .
#cp $product_dir/system/lib/libnvmm_image.so .
#cp $product_dir/system/lib/libnvmm_manager.so .
#cp $product_dir/system/lib/libnvmm_misc.so .
#cp $product_dir/system/lib/libnvmm_parser.so .
#cp $product_dir/system/lib/libnvmm_service.so .
#cp $product_dir/system/lib/libnvmm.so .
#cp $product_dir/system/lib/libnvmm_tracklist.so .
#cp $product_dir/system/lib/libnvmm_utils.so .
#cp $product_dir/system/lib/libnvmm_videorenderer.so .
#cp $product_dir/system/lib/libnvmm_video.so .
#cp $product_dir/system/lib/libnvmm_vp6_video.so .
#cp $product_dir/system/lib/libnvmm_writer.so .
#cp $product_dir/system/lib/libnvodm_dtvtuner.so .
#cp $product_dir/system/lib/libnvodm_hdmi.so .
#cp $product_dir/system/lib/libnvodm_imager.so .
#cp $product_dir/system/lib/libnvodm_misc.so .
#cp $product_dir/system/lib/libnvodm_query.so .
#cp $product_dir/system/lib/libnvomxilclient.so .
#cp $product_dir/system/lib/libnvomx.so .
cp $product_dir/system/lib/libnvos.so .
cp $product_dir/system/lib/libsync.so .
cp $product_dir/system/lib/libnvrm_graphics.so .
cp $product_dir/system/lib/libnvrm.so .
#cp $product_dir/system/lib/libnvsm.so .
#cp $product_dir/system/lib/libnvwinsys.so .
#cp $product_dir/system/lib/libnvwsi.so .

# NVIDIA test libraries
cp $product_dir/system/lib/libnvapputil.so .
#cp $product_dir/system/lib/libnvtestio.so .
#cp $product_dir/system/lib/libnvtestresults.so .
#cp $product_dir/system/lib/nvmm_audioverify_test.so .
#cp $product_dir/system/lib/nvmm_jpegenc_test.so .
#cp $product_dir/system/lib/nvmm_mpeg2vdec_test.so .
#cp $product_dir/system/lib/nvmm_videodec_test.so .
#cp $product_dir/system/lib/nvmm_videoenc_test.so .
#cp $product_dir/system/lib/nvwlantest.so .
#cp $product_dir/system/lib/omxplayer.so .

echo "Adding files to $product_dir/qt_ramdisk_tmpdir/system/lib/egl"
mkdir -p $product_dir/qt_ramdisk_tmpdir/system/lib/egl
cd $product_dir/qt_ramdisk_tmpdir/system/lib/egl
#cp $product_dir/system/lib/egl/libEGL_tegra.so .
#cp $product_dir/system/lib/egl/libGLESv1_CM_tegra.so .
#cp $product_dir/system/lib/egl/libGLESv2_tegra.so .

echo "Adding files to $product_dir/qt_ramdisk_tmpdir/system/xbin"
mkdir -p $product_dir/qt_ramdisk_tmpdir/system/xbin
cd $product_dir/qt_ramdisk_tmpdir/system/xbin
#cp $product_dir/system/xbin/scp .
#cp $product_dir/system/xbin/showslab .
#cp $product_dir/system/xbin/ssh .
#cp $product_dir/system/xbin/su .

# Copy needed BBC files for FPGA use
if [ $target_board == "dolak" ]; then
    echo "Adding Modem test files to $product_dir/nvtest_ramdisk_tmpdir/system/bin"
    cd $product_dir/nvtest_ramdisk_tmpdir/system/bin
    cp $product_dir/system/bin/nvshmtest .
    cp $product_dir/system/bin/ttytestapp .
    cp $product_dir/system/bin/fild .
    cp $product_dir/system/bin/icera_log_serial_arm .
    chmod 777 nvshmtest
    chmod 777 ttytestapp
    chmod 777 fild
    chmod 777 icera_log_serial_arm
    mkdir -p $product_dir/nvtest_ramdisk_tmpdir/data/rfs
    mkdir -p $product_dir/nvtest_ramdisk_tmpdir/data/rfs/app
    mkdir -p $product_dir/nvtest_ramdisk_tmpdir/data/rfs/data
    mkdir -p $product_dir/nvtest_ramdisk_tmpdir/data/rfs/data/debug
    mkdir -p $product_dir/nvtest_ramdisk_tmpdir/data/rfs/data/config
    mkdir -p $product_dir/nvtest_ramdisk_tmpdir/data/rfs/data/factory
    mkdir -p $product_dir/nvtest_ramdisk_tmpdir/data/rfs/data/modem
    # Copy firmware from binary icera repository
    cd $product_dir/nvtest_ramdisk_tmpdir/data/rfs/app
    cp $product_dir/system/vendor/firmware/app/secondary_boot.wrapped .
    cp $product_dir/system/vendor/firmware/app/modem.wrapped .
    cd $product_dir/nvtest_ramdisk_tmpdir/data/rfs/data/config
    cp $product_dir/system/vendor/firmware/data/config/audioConfig.bin .
    cp $product_dir/system/vendor/firmware/data/config/productConfig.bin .
    # These are not shipped in a normal builds but are mandatory for modem boot on fpga
    # ONLY FOR FPGA USE
    cd $product_dir/nvtest_ramdisk_tmpdir/data/rfs/data/factory
    cp $product_dir/system/vendor/firmware/data/factory/platformConfig.xml .
    cp $product_dir/system/vendor/firmware/data/factory/imei.bin .
    cp $product_dir/system/vendor/firmware/data/factory/deviceConfig.bin .
    cp $product_dir/system/vendor/firmware/data/factory/calibration_0.bin .
    cp $product_dir/system/vendor/firmware/data/factory/calibration_1.bin .
fi

echo "Adding files to $product_dir/qt_ramdisk_tmpdir/system/etc/firmware"
mkdir -p $product_dir/qt_ramdisk_tmpdir/system/etc/firmware
pushd $product_dir/qt_ramdisk_tmpdir/system/etc/firmware
cp -r $product_dir/system/etc/firmware/* .
popd

device_dir=$top/device/nvidia/$target_board
qt_init_rc=$device_dir/init.qt.rc
qt_init_board_rc=$device_dir/init.$target_board.qt.rc

if [ -f "$qt_init_rc" ]; then
    if [ -f "$qt_init_board_rc" ]; then
        echo "Replacing init.rc files with QT versions"
        echo cp $qt_init_rc $product_dir/qt_ramdisk_tmpdir/init.rc
        cp $qt_init_rc $product_dir/qt_ramdisk_tmpdir/init.rc
        echo cp $qt_init_board_rc $product_dir/qt_ramdisk_tmpdir/init.$target_board.rc
        cp $qt_init_board_rc $product_dir/qt_ramdisk_tmpdir/init.$target_board.rc
        echo "Removing standard components that are useless on QT"
        rm -f $product_dir/qt_ramdisk_tmpdir/init.goldfish.rc
        rm -f $product_dir/qt_ramdisk_tmpdir/ueventd.goldfish.rc
        rm -f $product_dir/qt_ramdisk_tmpdir/init.nv_dev_board.usb.rc
        rm -f $product_dir/qt_ramdisk_tmpdir/sbin/adbd
    fi
fi

# Package up the new ramdisk image
if [ -d $android_host_bin ]; then
    echo "Packaging new ramdisk contents as $product_dir/qt_ramdisk.img"
	$android_host_bin/mkbootfs $product_dir/qt_ramdisk_tmpdir > $product_dir/qt_ramdisk.img
else
    echo "ERROR: Host tools directory $android_host_bin does not exist"
    exit 2
fi

echo "Done"
exit 0
