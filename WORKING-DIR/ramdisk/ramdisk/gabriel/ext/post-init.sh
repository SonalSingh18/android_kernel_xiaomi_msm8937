#!/gabriel/busybox sh

# Kernel Tuning by Dorimanx.
# Kernel Tuning by Mostafaz.

BB=/gabriel/busybox

MEM_ALL=`free | grep Mem | $BB awk '{ print $2 }'`;

# protect init from oom
if [ -f /system/xbin/su ]; then
	su -c echo "-1000" > /proc/1/oom_score_adj;
fi;

OPEN_RW()
{
	if [ "$($BB mount | grep rootfs | cut -c 26-27 | grep -c ro)" -ge "0" ]; then
		$BB mount -o remount,rw /;
	fi;
	$BB mount -o remount,rw /system;
}
OPEN_RW;

if [ ! -e /sbin/busybox ];then
	$BB cp /gabriel/busybox /sbin/busybox;
	$BB chmod 06755 /sbin/busybox;
fi;

# some nice thing for dev
if [ ! -e /cpufreq ]; then
	$BB ln -s /sys/devices/system/cpu/cpu0/cpufreq/ /cpufreq_b;
	$BB ln -s /sys/devices/system/cpu/cpu4/cpufreq/ /cpufreq_l;
	$BB ln -s /sys/module/msm_thermal/parameters/ /cputemp;
fi;

# create init.d folder if missing
if [ ! -d /system/etc/init.d ]; then
	mkdir -p /system/etc/init.d/
	$BB chmod 755 /system/etc/init.d/;
fi;

OPEN_RW;

CRITICAL_PERM_FIX()
{
	# critical Permissions fix
	$BB chown -R root:root /tmp;
	$BB chown -R root:root /res;
	$BB chown -R root:root /sbin;
	$BB chown -R root:root /gabriel;
	$BB chmod -R 777 /tmp/;
	$BB chmod -R 775 /res/;
	$BB chmod -R 06755 /gabriel/ext/;
	$BB chmod 06755 /gabriel/busybox;
	$BB chmod 06755 /system/xbin/busybox;
}
CRITICAL_PERM_FIX;

$BB chmod 666 /sys/module/lowmemorykiller/parameters/cost;
$BB chmod 666 /sys/module/lowmemorykiller/parameters/adj;
$BB chmod 666 /sys/module/lowmemorykiller/parameters/minfree

$BB chmod 666 /sys/module/msm_thermal/parameters/*

for i in kcal kcal_cont kcal_hue kcal_invert kcal_sat kcal_val; do
	$BB chown system system /sys/devices/platform/kcal_ctrl.0/$i
	$BB chmod 0664 /sys/devices/platform/kcal_ctrl.0/$i
done;

for i in governor max_freq min_freq; do
	$BB chown system system /sys/class/devfreq/1c00000.qcom,kgsl-3d0/$i
	$BB chmod 0664 /sys/class/devfreq/1c00000.qcom,kgsl-3d0/$i
done;

for i in cpu1 cpu2 cpu3 cpu4 cpu5 cpu6 cpu7; do
	$BB chown system system /sys/devices/system/cpu/$i/online
	$BB chmod 0664 /sys/devices/system/cpu/$i/online
done;

for i in cpu0 cpu4; do
$BB chown system system /sys/devices/system/cpu/$i/cpufreq/*
$BB chown system system /sys/devices/system/cpu/$i/cpufreq/*
$BB chmod 0664 /sys/devices/system/cpu/$i/cpufreq/scaling_governor
$BB chmod 0664 /sys/devices/system/cpu/$i/cpufreq/scaling_max_freq
$BB chmod 0664 /sys/devices/system/cpu/$i/cpufreq/scaling_min_freq
$BB chmod 0444 /sys/devices/system/cpu/$i/cpufreq/cpuinfo_cur_freq
$BB chmod 0444 /sys/devices/system/cpu/$i/cpufreq/stats/*
done;

SYSTEM_TUNING()
{
# Tune entropy parameters.
echo "1024" > /proc/sys/kernel/random/read_wakeup_threshold;
echo "128" > /proc/sys/kernel/random/write_wakeup_threshold;

echo 8192 > /proc/sys/vm/min_free_kbytes
echo 70 > /proc/sys/vm/swappiness
echo 200 > /proc/sys/vm/dirty_expire_centisecs
echo 500 > /proc/sys/vm/dirty_writeback_centisecs
echo 90 > /proc/sys/vm/dirty_ratio
echo 70 > /proc/sys/vm/dirty_background_ratio
echo 10 > /proc/sys/vm/vfs_cache_pressure

if [ $MEM_ALL -lt "2900000000" ];then
	echo 1 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
	echo "18432,23040,27648,51256,89600,115200" > /sys/module/lowmemorykiller/parameters/minfree
	echo 128000 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
else
	echo 1 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
	echo "18432,23040,27648,51256,150296,200640" > /sys/module/lowmemorykiller/parameters/minfree
	echo 202640 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
fi;

# screen calibration
if [ ! -e /init.miui.rc ];then
	echo "237 235 255" > /sys/devices/platform/kcal_ctrl.0/kcal;
	echo "255" > /sys/devices/platform/kcal_ctrl.0/kcal_cont;
	echo "1515" > /sys/devices/platform/kcal_ctrl.0/kcal_hue;
	echo "35" > /sys/devices/platform/kcal_ctrl.0/kcal_min;
	echo "265" > /sys/devices/platform/kcal_ctrl.0/kcal_sat;
	echo "253" > /sys/devices/platform/kcal_ctrl.0/kcal_val;
fi;

if [ -e /init.miui.rc ]; then
	if [ -e /sys/android_touch/doubletap2wake ];then
		echo "2" > /sys/android_touch/doubletap2wake;
	fi;
fi;

if [ $MEM_ALL -lt "3000000000" ];then
	if [ -e /dev/block/zram0 ]; then
		$BB swapoff /dev/block/zram0 >/dev/null 2>&1;
		echo "1" > /sys/block/zram0/reset;
		echo "lz4" > /sys/block/zram0/comp_algorithm;
		echo "1GB" > /sys/block/zram0/disksize;
		$BB mkswap /dev/block/zram0 >/dev/null;
		$BB swapon /dev/block/zram0;
	fi;
fi;

# disable block iostats/rotational and set io-scheduler
for i in /sys/block/*/queue; do
	echo 0 > $i/iostats
	echo 0 > $i/rotational
	echo zen > $i/scheduler
	echo 2048 > $i/read_ahead_kb
done;
}

OLD_CONFIG()
{
echo 0 > /sys/module/workqueue/parameters/power_efficient;
echo 0 > /sys/module/msm_thermal/core_control/enabled;
echo 1 > /cputemp/enabled;

echo 0 > /proc/sys/kernel/sched_boost
echo 90 > /proc/sys/kernel/sched_downmigrate
echo 95 > /proc/sys/kernel/sched_upmigrate
echo 400000 > /proc/sys/kernel/sched_freq_inc_notify
echo 400000 > /proc/sys/kernel/sched_freq_dec_notify
echo 3 > /proc/sys/kernel/sched_spill_nr_run
echo 100 > /proc/sys/kernel/sched_init_task_load

echo 0 > /sys/devices/system/cpu/cpu0/sched_mostly_idle_freq
echo 0 > /sys/devices/system/cpu/cpu4/sched_mostly_idle_freq

# Little cluster
echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_sched_load
echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_migration_notif
echo 10000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
echo 80 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
echo 998400 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
echo "80" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
echo 20000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
echo 80000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/ignore_hispeed_on_notif
echo 99000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis
echo 80000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_slack
echo 0 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy

# big cluster
echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load
echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif
echo "20000 1094400:20000 1209600:20000 1401000:39000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
echo 80 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
echo 1094400 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
echo "80 1248000:90 1344000:80 1401000:95" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
echo 20000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
echo 80000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/ignore_hispeed_on_notif
echo 99000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/max_freq_hysteresis
echo 80000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_slack
echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy

# kgsl tuning
echo 'msm-adreno-tz' > /sys/class/kgsl/kgsl-3d0/devfreq/governor;
echo 160000000 > /sys/class/kgsl/kgsl-3d0/devfreq/min_freq;
echo 8 > /sys/class/devfreq/1c00000.qcom,kgsl-3d0/device/kgsl/kgsl-3d0/default_pwrlevel;
echo 1 > /sys/module/adreno_idler/parameters/adreno_idler_active;
echo 15 > /sys/module/adreno_idler/parameters/adreno_idler_idlewait;
echo 40 > /sys/module/adreno_idler/parameters/adreno_idler_downdifferential;
echo 5000 > /sys/module/adreno_idler/parameters/adreno_idler_idleworkload;

if [ -e /sys/module/cluster_plug/parameters/active ];then
	echo "1" > /sys/module/cluster_plug/parameters/active;
fi
}
#OLD_CONFIG;

# start CORTEX by tree root, so it's will not be terminated.
if [ "$(pgrep -f "cortexbrain-tune.sh" | wc -l)" -eq "0" ]; then
	nohup sh /gabriel/ext/cortexbrain-tune.sh > /data/.gabriel/cortex.txt &
fi;

OPEN_RW;

if [ ! -d /data/.gabriel ]; then
	$BB mkdir -p /data/.gabriel;
fi;

if [ ! -d /data/.gabriel/logs ]; then
	$BB mkdir -p /data/.gabriel/logs;
fi;

SYSTEM_TUNING;

$BB nohup $BB run-parts /system/etc/init.d/ > /data/.gabriel/init.d.txt &

if [ -e /system/etc/init.d/99SuperSUDaemon ]; then
	$BB nohup $BB sh /system/etc/init.d/99SuperSUDaemon > /data/.gabriel/root.txt &
else
	echo "no root script in init.d";
fi;

# Fix critical perms again after init.d mess
CRITICAL_PERM_FIX;

if [ "$(cat /system/build.prop | grep "ro.build.version.release" | cut -c 26)" -eq "7" ]; then
	echo 1 > /sys/fs/selinux/enforce;
fi;

# Fix titanium backup root access
if [ -e /sbin/su ] && [ -e /system/xbin/su ];then
	\cp /sbin/su /system/xbin/su;
fi;

# Fentropy enForcer
# Thanks to ArjunrambZ (TweakDrypT)
if [ -e "/dev/frandom" ]; then
	chmod 666 /dev/frandom;
	for dom in /dev/*random; do
		if [ "\$dom" != "/dev/frandom" ] && [ ! "\`ls \$dom.*\`" ]; then
			mv \$dom \$dom.unsuper;
			ln /dev/frandom \$dom;
			chmod 666 \$dom;
		fi 2>/dev/null;
	done;
fi;

# Load parameters for Synapse
DEBUG=/data/.gabriel/;
BUSYBOX_VER=$(busybox | grep "BusyBox v" | cut -c0-15);
echo "$BUSYBOX_VER" > $DEBUG/busybox_ver;

(
	sleep 10;

	for i in cpu0 cpu1 cpu2 cpu3; do
	echo 1401000 > /sys/devices/system/cpu/$i/cpufreq/scaling_max_freq
	echo 960000 > /sys/devices/system/cpu/$i/cpufreq/scaling_min_freq
	done;

	for i in cpu4 cpu5 cpu6 cpu7; do
	echo 1094400 > /sys/devices/system/cpu/$i/cpufreq/scaling_max_freq
	echo 768000 > /sys/devices/system/cpu/$i/cpufreq/scaling_min_freq
	done;

	# script finish here, so let me know when
	TIME_NOW=$(date)
	echo "$TIME_NOW" > /data/.gabriel/boot_log

	$BB mount -o remount,ro /system;
)&
