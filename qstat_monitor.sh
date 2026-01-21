#!/bin/bash
set -euo pipefail

# ============================================================
# Script Name : qstat_monitor.sh
# Description : Cluster job monitoring and statistics summary
#
# Author      : Abdullah Barghash
# Role        : HPC Engineer
# Created On  : 20 Jan 2026
#
# Notes       : Designed for PBS-based CentOS/RHEL HPC clusters
# ============================================================

QSTAT_OUT=$(qstat)
QSTAT_FX_OUT=$(qstat -fx)

echo "=============================="
echo "        PBS QSTAT MONITOR     "
echo "=============================="
echo

echo "=== Current Jobs ==="
echo "$QSTAT_OUT"
echo

echo "=== Job Counts ==="
echo "Total Jobs        : $(echo "$QSTAT_OUT" | awk 'NR>2' | wc -l)"
echo "FAT Jobs          : $(echo "$QSTAT_OUT" | grep -c ' fat ')"
echo "THIN Jobs         : $(echo "$QSTAT_OUT" | grep -c ' thin ')"
echo "A100 Jobs         : $(echo "$QSTAT_OUT" | grep -c ' A100 ')"
echo "H100 Jobs         : $(echo "$QSTAT_OUT" | grep -c ' H100 ')"
echo

echo "=== Top Users by Job Count ==="
echo "$QSTAT_OUT" | awk 'NR>2 {print $3}' | sort | uniq -c | sort -nr
echo

echo "=== Waiting (Q) Jobs per User ==="
echo "$QSTAT_OUT" | awk '$5=="Q" {print $3}' | sort | uniq -c | sort -nr
echo

echo "=== Scheduler Resource Usage per User ==="
echo "$QSTAT_FX_OUT" | awk '
/^Job Id:/ {
    user=""; ncpus=0; nodes=0; queue=""
}

/Job_Owner/ {
    split($3, owner, "@")
    user = owner[1]
}

/Resource_List\.ncpus/   { ncpus = $3 }
/Resource_List\.nodect/ { nodes = $3 }
/^    queue =/           { queue = $3 }

(user != "" && ncpus > 0 && nodes > 0 && queue != "") {
    jobs[user]++
    cpu[user]  += ncpus
    nd[user]   += nodes
    q[user,queue]++
    user=""; ncpus=0; nodes=0; queue=""
}

END {
    printf "%-18s %5s %6s %6s %8s %6s %6s %6s\n",
           "USER","JOBS","NODES","CPUS","THIN","FAT","A100","H100"
    printf "%-18s %5s %6s %6s %8s %6s %6s %6s\n",
           "------------------","-----","------","------","--------","------","------","------"

    for (usr in jobs) {
        printf "%-18s %5d %6d %6d %8d %6d %6d %6d\n",
               usr,
               jobs[usr],
               nd[usr],
               cpu[usr],
               q[usr,"thin"]+0,
               q[usr,"fat"]+0,
               q[usr,"A100"]+0,
               q[usr,"H100"]+0
    }
}' | sort -k2 -nr
echo

echo "=============================="
echo "          END OF REPORT       "
echo "=============================="
echo
echo "Date:"
/usr/bin/date
echo
echo "Calendar:"
/usr/bin/cal
