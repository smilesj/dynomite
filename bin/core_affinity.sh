#!/bin/bash
# Set core affinity for redis and dynomite processes
#

# Requires setting the EC2 Instance type as ENV variable.
# If Dynomite is used outside of AWS environment,
# the core affinity script can be configured accordingly.
echo "$EC2_INSTANCE_TYPE"

if [ "$EC2_INSTANCE_TYPE" == "r3.xlarge" ]; then
    dynomite_pid=`pgrep -f $DYN_DIR/bin/dynomite`
    echo "dynomite pid: $dynomite_pid"
    taskset -pac 2,3 $dynomite_pid

    redis_pid=`ps -ef | grep 22122 | grep redis | awk -F' '  '{print $2}'`
    sudo sh -c "echo -17 > /proc/${redis_pid}/oom_adj"

    echo "redis pid: $redis_pid"
    taskset -pac 1 $redis_pid

elif [ "$EC2_INSTANCE_TYPE" == "r3.4xlarge" ]; then
    dynomite_pid=`pgrep -f $DYN_DIR/bin/dynomite`
    echo "dynomite pid: $dynomite_pid"
    taskset -pac 1,2,3,4,5,9,10,11,12,13 $dynomite_pid

    redis_pid=`ps -ef | grep 22122 | grep redis | awk -F' '  '{print $2}'`
    echo "redis pid: $redis_pid"
    sudo sh -c "echo -17 > /proc/${redis_pid}/oom_adj"
    taskset -pac 6,7,14,15 $redis_pid


else
    dynomite_pid=`pgrep -f $DYN_DIR/bin/dynomite`
    echo "dynomite pid: $dynomite_pid"
    taskset -pac 2,5,6 $dynomite_pid

    redis_pid=`ps -ef | grep 22122 | grep redis | awk -F' '  '{print $2}'`
    echo "redis pid: $redis_pid"
    sudo sh -c "echo -17 > /proc/${redis_pid}/oom_adj"
    taskset -pac 3,7 $redis_pid

fi
