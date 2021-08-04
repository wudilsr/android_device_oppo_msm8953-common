#! /vendor/bin/sh

# Copyright (c) 2012-2013,2016,2018,2019 The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

export PATH=/vendor/bin

# Set platform variables
if [ -f /sys/devices/soc0/soc_id ]; then
    soc_hwid=`cat /sys/devices/soc0/soc_id` 2> /dev/null
else
    soc_hwid=`cat /sys/devices/system/soc/soc0/id` 2> /dev/null
fi


log -t BOOT -p i "MSM target '$1', HwID '$soc_hwid'"

#For drm based display driver
vbfile=/sys/module/drm/parameters/vblankoffdelay
if [ -w $vbfile ]; then
    echo -1 >  $vbfile
else
    log -t DRM_BOOT -p w "file: '$vbfile' or perms doesn't exist"
fi

# Set vendor.opengles.version based on chip id.
# MSM8937 and MSM8940  variants supports OpenGLES 3.1
# 196608 is decimal for 0x30000 to report version 3.0
# 196609 is decimal for 0x30001 to report version 3.1
# 196610 is decimal for 0x30002 to report version 3.2
case "$soc_hwid" in
    294|295|296|297|298|313|353|354|363|364)
        setprop vendor.opengles.version 196610
        if [ $soc_hwid = 354 ]
        then
            setprop vendor.media.target.version 1
            log -t BOOT -p i "SDM429 early_boot prop set for: HwID '$soc_hwid'"
        fi
        ;;
    303|307|308|309|320)
        # Vulkan is not supported for 8917 variants
        setprop vendor.opengles.version 196608
        setprop persist.graphics.vulkan.disable true
        # Add by AMT.meng.lv,12/05/2019,for "vulkan and opengles issue between 8917, 8940 and 8937 chips" begin
        setprop persist.vendor.graphics.vulkan.disable true
        # Add by AMT.meng.lv,12/05/2019,for "vulkan and opengles issue between 8917, 8940 and 8937 chips" end
        ;;
    *)
        setprop vendor.opengles.version 196608
        ;;
esac

setprop persist.vendor.radio.atfwd.start true;;

# Setup display nodes & permissions
# HDMI can be fb1 or fb2
# Loop through the sysfs nodes and determine
# the HDMI(dtv panel)

function set_perms() {
    #Usage set_perms <filename> <ownership> <permission>
    chown -h $2 $1
    chmod $3 $1
}

# check for the type of driver FB or DRM
fb_driver=/sys/class/graphics/fb0
if [ -e "$fb_driver" ]
then
    # check for mdp caps
    file=/sys/class/graphics/fb0/mdp/caps
    if [ -f "$file" ]
    then
        setprop vendor.gralloc.disable_ubwc 1
        cat $file | while read line; do
          case "$line" in
                    *"ubwc"*)
                    setprop vendor.gralloc.enable_fb_ubwc 1
                    setprop vendor.gralloc.disable_ubwc 0
                esac
        done
    fi
else
    set_perms /sys/devices/virtual/hdcp/msm_hdcp/min_level_change system.graphics 0660
fi

# allow system_graphics group to access pmic secure_mode node
set_perms /sys/class/lcd_bias/secure_mode system.graphics 0660
set_perms /sys/class/leds/wled/secure_mode system.graphics 0660

boot_reason=`cat /proc/sys/kernel/boot_reason`
reboot_reason=`getprop ro.boot.alarmboot`
if [ "$boot_reason" = "3" ] || [ "$reboot_reason" = "true" ]; then
    setprop ro.vendor.alarm_boot true
else
    setprop ro.vendor.alarm_boot false
fi

# copy GPU frequencies to vendor property
if [ -f /sys/class/kgsl/kgsl-3d0/gpu_available_frequencies ]; then
    gpu_freq=`cat /sys/class/kgsl/kgsl-3d0/gpu_available_frequencies` 2> /dev/null
    setprop vendor.gpu.available_frequencies "$gpu_freq"
fi
