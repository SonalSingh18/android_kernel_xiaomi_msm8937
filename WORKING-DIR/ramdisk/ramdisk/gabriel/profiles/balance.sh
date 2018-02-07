#!/system/bin/sh
# created by mostafaz@xda

(
sleep 30;

GOV=interactive
TARGET0="1 960000:35 1094400:50 1209600:65 1248000:85 1344000:90 1401000:99"
TARGET4="1 768000:35 902400:50 998400:80 1094400:100"

for i in 0 1 2 3; do
	CPUB=sys/devices/system/cpu/cpu$i/cpufreq
    if [ "$(cat /sys/devices/system/cpu/cpu$i/online)" == "1" ];then
    	chmod 644 /$CPUB/scaling_governor
	    echo "interactive" > /$CPUB/scaling_governor
	    chmod 444 /$CPUB/scaling_governor
	    chmod 644 /$CPUB/$GOV/*
	    echo 0 > /$CPUB/$GOV/use_sched_load
	    echo 0 > /$CPUB/$GOV/use_migration_notif
	    echo 0 > /$CPUB/$GOV/enable_prediction
	    echo 0 > /$CPUB/$GOV/above_hispeed_delay
	    echo 300 > /$CPUB/$GOV/go_hispeed_load
	    echo 1094400 > /$CPUB/$GOV/hispeed_freq
	    echo "$TARGET0" > /$CPUB/$GOV/target_loads
	    echo 40000 > /$CPUB/$GOV/timer_rate
	    echo 0 > /$CPUB/$GOV/min_sample_time
	    echo 1 > /$CPUB/$GOV/ignore_hispeed_on_notif
	    echo 0 > /$CPUB/$GOV/max_freq_hysteresis
	    echo -1 > /$CPUB/$GOV/timer_slack
	    echo 0 > /$CPUB/$GOV/io_is_busy
    	echo 0 > /$CPUB/$GOV/boost
    	echo 80000 > /$CPUB/$GOV/boostpulse_duration
	    echo 0 > /$CPUB/$GOV/fast_ramp_down
    	echo 1401000 > /$CPUB/scaling_max_freq
        break
    fi;
done;

for i in 4 5 6 7; do
	CPUL=sys/devices/system/cpu/cpu$i/cpufreq
    if [ "$(cat /sys/devices/system/cpu/cpu$i/online)" == "1" ];then
    	chmod 644 /$CPUL/scaling_governor
    	echo "interactive" > /$CPUL/scaling_governor
    	chmod 444 /$CPUL/scaling_governor
    	chmod 644 /$CPUL/$GOV/*
    	echo 0 > /$CPUL/$GOV/use_sched_load
    	echo 1 > /$CPUL/$GOV/use_migration_notif
    	echo 0 > /$CPUL/$GOV/enable_prediction
    	echo 0 > /$CPUL/$GOV/above_hispeed_delay
    	echo 300 > /$CPUL/$GOV/go_hispeed_load
    	echo 998400 > /$CPUL/$GOV/hispeed_freq
    	echo "$TARGET4" > /$CPUL/$GOV/target_loads
    	echo 20000 > /$CPUL/$GOV/timer_rate
    	echo 0 > /$CPUL/$GOV/min_sample_time
    	echo 1 > /$CPUL/$GOV/ignore_hispeed_on_notif
    	echo 0 > /$CPUL/$GOV/max_freq_hysteresis
    	echo -1 > /$CPUL/$GOV/timer_slack
    	echo 0 > /$CPUL/$GOV/io_is_busy
    	echo 0 > /$CPUL/$GOV/boost
    	echo 80000 > /$CPUL/$GOV/boostpulse_duration
    	echo 0 > /$CPUL/$GOV/fast_ramp_down
    	echo 1094400 > /$CPUL/scaling_max_freq
        break
    fi;
done;

echo 1 > /sys/module/msm_thermal/core_control/enabled
echo 0 > /sys/module/msm_thermal/parameters/enabled
echo "msm-adreno-tz" > /sys/class/kgsl/kgsl-3d0/devfreq/governor
echo 160000000 > /sys/class/kgsl/kgsl-3d0/devfreq/min_freq
echo 475000000 > /sys/class/kgsl/kgsl-3d0/devfreq/max_freq
echo 8 > /sys/class/devfreq/1c00000.qcom,kgsl-3d0/device/kgsl/kgsl-3d0/default_pwrlevel
echo 1 > /sys/module/adreno_idler/parameters/adreno_idler_active
echo 15 > /sys/module/adreno_idler/parameters/adreno_idler_idlewait
echo 40 > /sys/module/adreno_idler/parameters/adreno_idler_downdifferential
echo 5000 > /sys/module/adreno_idler/parameters/adreno_idler_idleworkload
echo "zen"> /sys/block/mmcblk0/queue/scheduler
echo 1 > /sys/module/workqueue/parameters/power_efficient
echo 1 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lm
echo "westwood" > /proc/sys/net/ipv4/tcp_congestion_control

echo "[Gabriel-Kernel] spectrum: balance profile loaded" > /dev/kmsg
)&
