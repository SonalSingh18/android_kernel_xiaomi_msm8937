#!/system/bin/sh
# created by mostafaz@xda

(
sleep 30;

GOV=interactive
TARGET0="65 960000:75 1094400:80 1209600:99 1248000:97 1344000:99 1401000:99"
TARGET4="71 768000:70 902400:77 998400:87 1094400:99"

for i in 0 1 2 3; do
	CPUB=sys/devices/system/cpu/cpu$i/cpufreq
	if [ "$(cat /sys/devices/system/cpu/cpu$i/online)" == "1" ];then
		chmod 644 /$CPUB/scaling_governor
		echo "interactive" > /$CPUB/scaling_governor
		chmod 444 /$CPUB/scaling_governor
		chmod 644 /$CPUB/$GOV/*
		echo 0 > /$CPUB/$GOV/use_sched_load
		echo 1 > /$CPUB/$GOV/use_migration_notif
		echo 0 > /$CPUB/$GOV/enable_prediction
		echo "20000 1094400:20000 1209600:20000 1401000:39000" > /$CPUB/$GOV/above_hispeed_delay
		echo 400 > /$CPUB/$GOV/go_hispeed_load
		echo 960000 > /$CPUB/$GOV/hispeed_freq
		echo "$TARGET0" > /$CPUB/$GOV/target_loads
		echo 96666 > /$CPUB/$GOV/timer_rate
		echo 96666 > /$CPUB/$GOV/sleep_timer_rate
		echo 11000 > /$CPUB/$GOV/min_sample_time
		echo 1 > /$CPUB/$GOV/ignore_hispeed_on_notif
		echo 0 > /$CPUB/$GOV/max_freq_hysteresis
		echo 160000 > /$CPUB/$GOV/timer_slack
		echo 0 > /$CPUB/$GOV/io_is_busy
		echo 0 > /$CPUL/$GOV/boost
		echo 0 > /$CPUL/$GOV/boostpulse_duration
		echo 1 > /$CPUB/$GOV/fast_ramp_down
		echo 1248000 > /$CPUB/scaling_max_freq
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
		echo 10000 > /$CPUL/$GOV/above_hispeed_delay
		echo 155 > /$CPUL/$GOV/go_hispeed_load
		echo 768000 > /$CPUL/$GOV/hispeed_freq
		echo "$TARGET4" > /$CPUL/$GOV/target_loads
		echo 86666 > /$CPUL/$GOV/timer_rate
		echo 86666 > /$CPUL/$GOV/sleep_timer_rate
		echo 23000 > /$CPUL/$GOV/min_sample_time
		echo 0 > /$CPUL/$GOV/ignore_hispeed_on_notif
		echo 0 > /$CPUL/$GOV/max_freq_hysteresis
		echo 145000 > /$CPUL/$GOV/timer_slack
		echo 0 > /$CPUL/$GOV/io_is_busy
		echo 1 > /$CPUL/$GOV/boost
		echo 0 > /$CPUL/$GOV/boostpulse_duration
		echo 0 > /$CPUL/$GOV/fast_ramp_down
		echo 998400 > /$CPUL/scaling_max_freq
        break
    fi;
done;

echo 2 > /proc/sys/kernel/sched_window_stats_policy
echo 90 > /proc/sys/kernel/sched_upmigrate
echo 65 > /proc/sys/kernel/sched_downmigrate
echo 7 > /proc/sys/kernel/sched_spill_nr_run
echo 97 > /proc/sys/kernel/sched_spill_load
echo 30 > /proc/sys/kernel/sched_init_task_load
echo 7 > /proc/sys/kernel/sched_upmigrate_min_nice
echo 4 > /proc/sys/kernel/sched_ravg_hist_size
echo 950000 > /proc/sys/kernel/sched_rt_runtime_us
echo 1000000 > /proc/sys/kernel/sched_rt_period_us
echo 5 > /proc/sys/kernel/sched_new_task_windows
if [ -e "/proc/sys/kernel/sched_heavy_task" ]; then
    echo 96 > /proc/sys/kernel/sched_heavy_task
fi
if [ -e "/proc/sys/kernel/sched_enable_power_aware" ]; then
    echo 1 > /proc/sys/kernel/sched_enable_power_aware
fi
if [ -e "/proc/sys/kernel/sched_small_wakee_task_load" ]; then
	echo 15 > /proc/sys/kernel/sched_small_wakee_task_load
fi
if [ -e "/proc/sys/kernel/sched_wakeup_load_threshold" ]; then
	echo 110 > /proc/sys/kernel/sched_wakeup_load_threshold
fi
if [ -e "/proc/sys/kernel/sched_small_task" ]; then
	echo 15 > /proc/sys/kernel/sched_small_task
fi
if [ -e "/proc/sys/kernel/sched_big_waker_task_load" ]; then
	echo 33 > /proc/sys/kernel/sched_big_waker_task_load
fi
if [ -e "/proc/sys/kernel/sched_migration_fixup" ]; then
	echo 1 > /proc/sys/kernel/sched_migration_fixup
fi
if [ -e "/proc/sys/kernel/sched_freq_dec_notify" ]; then
	echo 410000 > /proc/sys/kernel/sched_freq_dec_notify
fi
if [ -e "/proc/sys/kernel/sched_freq_inc_notify" ]; then
	echo 610000 > /proc/sys/kernel/sched_freq_inc_notify
fi
if [ -e "/proc/sys/kernel/sched_boost" ]; then
	echo 0 > /proc/sys/kernel/sched_boost
fi

echo 1 > /sys/module/msm_thermal/core_control/enabled
echo 0 > /sys/module/msm_thermal/parameters/enabled
echo "powersave" > /sys/class/kgsl/kgsl-3d0/devfreq/governor
echo 160000000 > /sys/class/kgsl/kgsl-3d0/devfreq/min_freq
echo 375000000 > /sys/class/kgsl/kgsl-3d0/devfreq/max_freq
echo 8 > /sys/class/devfreq/1c00000.qcom,kgsl-3d0/device/kgsl/kgsl-3d0/default_pwrlevel
echo 1 > /sys/module/adreno_idler/parameters/adreno_idler_active
echo 15 > /sys/module/adreno_idler/parameters/adreno_idler_idlewait
echo 40 > /sys/module/adreno_idler/parameters/adreno_idler_downdifferential
echo 5000 > /sys/module/adreno_idler/parameters/adreno_idler_idleworkload
echo "noop"> /sys/block/mmcblk0/queue/scheduler
echo 1 > /sys/module/workqueue/parameters/power_efficient
echo 0 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lm
echo "westwood" > /proc/sys/net/ipv4/tcp_congestion_control

echo -n disable > /sys/devices/soc/soc:qcom,bcl/mode

echo "[Gabriel-Kernel] spectrum: battery profile loaded" > /dev/kmsg
)&
