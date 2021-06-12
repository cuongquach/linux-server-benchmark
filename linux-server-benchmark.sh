#!/bin/bash
#######################################################
# Linux Server Benchmark
# Website: https://cuongquach.com/
#######################################################

# Color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PLAIN='\033[0m'

# Functions
break_line() {
    echo "----------------------------------------------------------------------"
}

io_test() {
    (LANG=C dd if=/dev/zero of=/tmp/test_$$ bs=64k count=16k conv=fdatasync && rm -f /tmp/test_$$ && sync && echo 3 > /proc/sys/vm/drop_caches ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//'
}

dd_test() {
    IO1=$( io_test )
    echo "I/O (1st run)        : $IO1"
    IO2=$( io_test )
    echo "I/O (2nd run)        : $IO2"
    IO3=$( io_test )
    echo "I/O (3rd run)        : $IO3"

    IORAW1=$( echo $IO1 | awk 'NR==1 {print $1}' )
    [ "`echo $IO1 | awk 'NR==1 {print $2}'`" == "GB/s" ] && IORAW1=$( awk 'BEGIN{print '$IORAW1' * 1024}' )
    IORAW2=$( echo $IO2 | awk 'NR==1 {print $1}' )
    [ "`echo $IO2 | awk 'NR==1 {print $2}'`" == "GB/s" ] && IORAW2=$( awk 'BEGIN{print '$IORAW2' * 1024}' )
    IORAW3=$( echo $IO3 | awk 'NR==1 {print $1}' )
    [ "`echo $IO3 | awk 'NR==1 {print $2}'`" == "GB/s" ] && IORAW3=$( awk 'BEGIN{print '$IORAW3' * 1024}' )
    IOALL=$( awk 'BEGIN{print '$IORAW1' + '$IORAW2' + '$IORAW3'}' )
    IOAVG=$( awk 'BEGIN{printf "%.1f", '$IOALL' / 3}' )
    echo "Average              : $IOAVG MB/s"
}

fio_test_basic() {
    RESULT_TEST_FIO=$(mktemp /tmp/benchmark-disk-fio-XXXXXXXX)
    fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=fio_test --filename=fio_test --bs=4k --numjobs=1 --iodepth=64 --size=256M --readwrite=randrw --rwmixread=75 --runtime=30 --time_based --output="$RESULT_TEST_FIO" > /dev/null 2>&1

    if [ $(fio -v | cut -d '.' -f 1) == "fio-2" ]; then
        local iops_read=`grep "iops=" "$RESULT_TEST_FIO" | grep read | awk -F[=,]+ '{print $6}'`
        local iops_write=`grep "iops=" "$RESULT_TEST_FIO" | grep write | awk -F[=,]+ '{print $6}'`
        local bw_read=`grep "bw=" "$RESULT_TEST_FIO" | grep read | awk -F[=,B]+ '{if(match($4, /[0-9]+K$/)) {printf("%.1f", int($4)/1024);} else if(match($4, /[0-9]+M$/)) {printf("%.1f", substr($4, 0, length($4)-1))} else {printf("%.1f", int($4)/1024/1024);}}'`"MB/s"
        local bw_write=`grep "bw=" "$RESULT_TEST_FIO" | grep write | awk -F[=,B]+ '{if(match($4, /[0-9]+K$/)) {printf("%.1f", int($4)/1024);} else if(match($4, /[0-9]+M$/)) {printf("%.1f", substr($4, 0, length($4)-1))} else {printf("%.1f", int($4)/1024/1024);}}'`"MB/s"

    elif [ $(fio -v | cut -d '.' -f 1) == "fio-3" ]; then
        local iops_read=`grep "IOPS=" "$RESULT_TEST_FIO" | grep read | awk -F[=,]+ '{print $2}'`
        local iops_write=`grep "IOPS=" "$RESULT_TEST_FIO" | grep write | awk -F[=,]+ '{print $2}'`
        local bw_read=`grep "bw=" "$RESULT_TEST_FIO" | grep READ | awk -F"[()]" '{print $2}'`
        local bw_write=`grep "bw=" "$RESULT_TEST_FIO" | grep WRITE | awk -F"[()]" '{print $2}'`
    fi

    echo "Read performance     : $bw_read"
    echo "Read IOPS            : $iops_read"
    echo "Write performance    : $bw_write"
    echo "Write IOPS           : $iops_write"
    echo ""
    echo ""

    rm -f $RESULT_TEST_FIO fio_test
}

speed_test() {
    local speedtest=$(wget -4O /dev/null -T300 $1 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}')
    local ipaddress=$(ping -c1 -4 -n `awk -F'/' '{print $3}' <<< $1` | awk -F'[()]' '{print $2;exit}')
    local nodeName=$2
    printf "${YELLOW}%-40s${GREEN}%-16s${RED}%-14s${PLAIN}\n" "${nodeName}" "${ipaddress}" "${speedtest}"
}

speed() {
    speed_test 'http://cachefly.cachefly.net/100mb.test' 'CacheFly'
    speed_test 'https://lax-ca-us-ping.vultr.com/vultr.com.100MB.bin' 'Vultr, Los Angeles, CA'
    speed_test 'https://wa-us-ping.vultr.com/vultr.com.100MB.bin' 'Vultr, Seattle, WA'
    speed_test 'http://speedtest.tokyo2.linode.com/100MB-tokyo.bin' 'Linode, Tokyo, JP'
    speed_test 'http://speedtest.singapore.linode.com/100MB-singapore.bin' 'Linode, Singapore, SG'
    speed_test 'http://speedtest.hkg02.softlayer.com/downloads/test100.zip' 'Softlayer, HongKong, CN'
    speed_test 'http://speedtest1.vtn.com.vn/speedtest/random4000x4000.jpg' 'VNPT, Ha Noi, VN'
    speed_test 'http://speedtest5.vtn.com.vn/speedtest/random4000x4000.jpg' 'VNPT, Da Nang, VN'
    speed_test 'http://speedtest3.vtn.com.vn/speedtest/random4000x4000.jpg' 'VNPT, Ho Chi Minh, VN'
    speed_test 'http://speedtestkv1a.viettel.vn/speedtest/random4000x4000.jpg' 'Viettel Network, Ha Noi, VN'
    speed_test 'http://speedtestkv2a.viettel.vn/speedtest/random4000x4000.jpg' 'Viettel Network, Da Nang, VN'
    speed_test 'http://speedtestkv3a.viettel.vn/speedtest/random4000x4000.jpg' 'Viettel Network, Ho Chi Minh, VN'
    speed_test 'http://speedtesthn.fpt.vn/speedtest/random4000x4000.jpg' 'FPT Telecom, Ha Noi, VN'
    speed_test 'http://speedtest.fpt.vn/speedtest/random4000x4000.jpg' 'FPT Telecom, Ho Chi Minh, VN'

    echo ""
    echo ""
}

#ioping test latency
ioping_test() {
    # A tool to monitor I/O latency in real time. It shows disk latency in the same way as ping shows network latency.
    latency=$(ioping -c 10 .|tail -1|cut -d "/" -f5|awk '{print $1$2}')
    echo "Latency              : $latency"
    echo ""
    echo ""
}

#sysbench CPU
sysbench_test_cpu() {
    RESULT_TEST_CPU=$(mktemp /tmp/benchmark-cpu-XXXXXXXX)
    sysbench cpu --cpu-max-prime=20000 run | grep -E 'time:|avg:|max:' |cut -d ":" -f2 > "${RESULT_TEST_CPU}"
    
    TOTAL_TIME=$(cat ${RESULT_TEST_CPU} | awk '{print $1}' | sed '1!d')
    AVG_TIME=$(cat ${RESULT_TEST_CPU} | awk '{print $1}' | sed '2!d')
    MAX_TIME=$(cat ${RESULT_TEST_CPU} | awk '{print $1}' | sed '3!d')

    # Result
    echo "Total Time           : ${TOTAL_TIME}"
    echo "Average Time         : ${AVG_TIME} ms"
    echo "Maximum Time         : ${MAX_TIME} ms"
    echo ""
    echo ""

    rm -f ${RESULT_TEST_CPU} > /dev/null 2>&1
}

#sysbench RAM
sysbench_test_memory() {
    RESULT_TEST_MEM=$(mktemp /tmp/benchmark-mem-XXXXXXXX)
    sysbench memory --memory-block-size=1K --memory-scope=global --memory-total-size=100G --memory-oper=read run|grep 'sec'|cut -d "(" -f2|cut -d ")" -f1 > ${RESULT_TEST_MEM}.read
    sysbench memory --memory-block-size=1K --memory-scope=global --memory-total-size=100G --memory-oper=write run|grep 'sec'|cut -d "(" -f2|cut -d ")" -f1 > ${RESULT_TEST_MEM}.write
    
    READ_OPERATION_PERFORM=$(cat ${RESULT_TEST_MEM}.read|sed '1!d')
    READ_TRANSFER=$(cat ${RESULT_TEST_MEM}.read | sed '2!d')
    WRITE_OPERATION_PERFORM=$(cat ${RESULT_TEST_MEM}.write | sed '1!d')
    WRITE_TRANSFER=$(cat ${RESULT_TEST_MEM}.write | sed '2!d')

    echo "READ Operations Performed      : ${READ_OPERATION_PERFORM}"
    echo "READ Transferred               : ${READ_TRANSFER}"
    echo "WRITE Operations Performed     : ${WRITE_OPERATION_PERFORM}"
    echo "WRITE Transferred              : ${WRITE_TRANSFER}"
    echo ""
    echo ""

    rm -f ${RESULT_TEST_MEM} ${RESULT_TEST_MEM}.read ${RESULT_TEST_MEM}.write > /dev/null 2>&1
}

get_opsy() {
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

calc_disk() {
    local total_size=0
    local array=$@
    for size in ${array[@]}
    do
        [ "${size}" == "0" ] && size_t=0 || size_t=`echo ${size:0:${#size}-1}`
        [ "`echo ${size:(-1)}`" == "M" ] && size=$( awk 'BEGIN{printf "%.1f", '$size_t' / 1024}' )
        [ "`echo ${size:(-1)}`" == "T" ] && size=$( awk 'BEGIN{printf "%.1f", '$size_t' * 1024}' )
        [ "`echo ${size:(-1)}`" == "G" ] && size=${size_t}
        total_size=$( awk 'BEGIN{printf "%.1f", '$total_size' + '$size'}' )
    done
    echo ${total_size}
}

system_info() {
    cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
    cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
    freq=$( awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
    tram=$( free -m | awk '/Mem/ {print $2}' )
    uram=$( free -m | awk '/Mem/ {print $3}' )
    swap=$( free -m | awk '/Swap/ {print $2}' )
    uswap=$( free -m | awk '/Swap/ {print $3}' )
    up=$( awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60} {printf("%d days, %d hour %d min\n",a,b,c)}' /proc/uptime )
    load=$( w | head -1 | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//' )
    opsy=$( get_opsy )
    arch=$( uname -m )
    lbit=$( getconf LONG_BIT )
    kern=$( uname -r )
    date=$( date )
    disk_size1=($( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $2}' ))
    disk_size2=($( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $3}' ))
    disk_total_size=$( calc_disk ${disk_size1[@]} )
    disk_used_size=$( calc_disk ${disk_size2[@]} )
    virtua=$(virt-what | head -n 1)
    [[ ${virtua} ]] && virt="$virtua" || virt="No Virtual found"

    echo "CPU model            : $cname"
    echo "Number of cores      : $cores"
    echo "CPU frequency        : $freq MHz"
    echo "Total size of Disk   : $disk_total_size GB ($disk_used_size GB Used)"
    echo "Total amount of Mem  : $tram MB ($uram MB Used)"
    echo "Total amount of Swap : $swap MB ($uswap MB Used)"
    echo "System uptime        : $up"
    echo "Load average         : $load"
    echo "OS                   : $opsy"
    echo "Arch                 : $arch ($lbit Bit)"
    echo "Kernel               : $kern"
    echo "Virt                 : $virt"
    echo "Date                 : $date"
    echo ""
    echo ""
}

install_dep_tools() {
    opsy=$( get_opsy )
    if  [ ! -e '/usr/bin/wget' ] || [ ! -e '/usr/bin/fio' ] || [ ! -e '/usr/bin/ioping' ] || [ ! -e '/usr/bin/sysbench' ] ||  [ ! -e '/usr/sbin/virt-what' ];then
        echo -e "Installing the required software. Please wait..."

        # Amazon Linux 2
        if [[ "${opsy}" == "Amazon Linux 2" ]];then
            yum clean all > /dev/null 2>&1
            amazon-linux-extras install epel -y > /dev/null 2>&1
            yum install -y wget fio ioping sysbench virt-what
        fi
        yum clean all > /dev/null 2>&1 && yum install -y epel-release > /dev/null 2>&1 && yum install -y wget fio ioping sysbench virt-what > /dev/null 2>&1 || ( apt-get update > /dev/null 2>&1 && apt-get install -y wget fio ioping sysbench virt-what > /dev/null 2>&1 )
    fi
}

main() {
    # check root
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Error:${PLAIN} This script must be run as root!"
        exit 1
    fi
    
    # Check dependencies tools
    echo "Please wait..."
    install_dep_tools

    # Clear console
    clear

    # System info
    echo "System Information"
    break_line
    system_info

    # Disk Spead
    echo "Disk Speed"
    break_line
    ## dd test
    echo "> **dd** Test"
    dd_test
    echo ""
    echo "> **fio** Test"
    fio_test_basic

    # Disk Ping Latency Test
    echo "Disk Latency"
    break_line
    ioping_test

    # Stress Test CPU
    echo "CPU Stress Test"
    break_line
    sysbench_test_cpu

    # Stress Test Memory
    echo "Memory (RAM) Stress Test"
    break_line
    sysbench_test_memory

    # Speedtest
    echo "Speedtest"
    break_line
    speed

    # Information
    echo "Visit website: https://cuongquach.com/"
}

main

exit 0
