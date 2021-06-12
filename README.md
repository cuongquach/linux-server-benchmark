# linux-server-benchmark

This script will help you to benchmark your Linux Server. From that you can understand more about the power of your Linux server.

## Supported Linux OS

- CentOS
- Ubuntu
- Debian
- Amazon Linux 2

## Usage

```
# curl -Lso- https://raw.githubusercontent.com/cuongquach/linux-server-benchmark/main/linux-server-benchmark.sh | bash
```

## Example Output

```
System Information
----------------------------------------------------------------------
CPU model            : Intel(R) Xeon(R) CPU E5-2630 v4 @ 2.20GHz
Number of cores      : 1
CPU frequency        : 2199.998 MHz
Total size of Disk   : 21.5 GB (4.5 GB Used)
Total amount of Mem  : 1987 MB (167 MB Used)
Total amount of Swap : 0 MB (0 MB Used)
System uptime        : 0 days, 3 hour 19 min
Load average         : 0.00, 0.02, 0.05
OS                   : Ubuntu 20.04 LTS
Arch                 : x86_64 (64 Bit)
Kernel               : 5.4.0-40-generic
Virt                 : kvm
Date                 : Sat 12 Jun 2021 07:06:18 AM UTC


Disk Speed
----------------------------------------------------------------------
> *dd* Test
I/O (1st run)        : 456 MB/s
I/O (2nd run)        : 474 MB/s
I/O (3rd run)        : 488 MB/s
Average              : 472.7 MB/s

> **fio** Test
Read performance     : 9253kB/s
Read IOPS            : 2259
Write performance    : 3075kB/s
Write IOPS           : 750


Disk Latency
----------------------------------------------------------------------
Latency              : 1.35ms


CPU Stress Test
----------------------------------------------------------------------
Total Time           : 10.0019s
Average Time         : 5.41 ms
Maximum Time         : 43.63 ms


Memory (RAM) Stress Test
----------------------------------------------------------------------
READ Operations Performed      : 2668929.76 per second
READ Transferred               : 2606.38 MiB/sec
WRITE Operations Performed     : 2044489.21 per second
WRITE Transferred              : 1996.57 MiB/sec


Speedtest
----------------------------------------------------------------------
CacheFly                                205.234.175.175 9.86MB/s
Vultr, Los Angeles, CA                  108.61.219.200  7.64MB/s
Vultr, Seattle, WA                      108.61.194.105  10.2MB/s
Linode, Tokyo, JP                       139.162.65.37   11.0MB/s
Linode, Singapore, SG                   139.162.23.4    7.82MB/s
Softlayer, HongKong, CN                 119.81.130.170  6.18MB/s
VNPT, Ha Noi, VN                        113.164.24.102  11.4MB/s
VNPT, Da Nang, VN                       113.164.16.66   10.8MB/s
VNPT, Ho Chi Minh, VN                   113.164.8.250   10.3MB/s
Viettel Network, Ha Noi, VN             27.68.226.129   11.1MB/s
Viettel Network, Da Nang, VN            27.68.201.1     11.2MB/s
Viettel Network, Ho Chi Minh, VN        27.68.239.33    4.60MB/s
FPT Telecom, Ha Noi, VN                 118.70.115.12
FPT Telecom, Ho Chi Minh, VN            1.55.119.15     11.1MB/s
```

## Visit

**Website** : [https://cuongquach.com/](https://cuongquach.com/)
