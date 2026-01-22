#!/bin/bash
set -euo pipefail

# ============================================================
# Script Name : qstat_monitor.sh
# Description : Cluster job monitoring and statistics summary
#
# Author      : Abdullah Barghash
# Role        : HPC Engineer
# Created On  : 2022 Jan 2026
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
#!/bin/bash

echo "=== Resource Usage / Summary (Per User & Group) ==="
echo

qstat -fx | awk '
BEGIN {
    printf "%-15s %-12s %-10s %-8s %-10s\n", "USER", "GROUP", "QUEUE", "JOBS", "NCPUS"
    printf "%-15s %-12s %-10s %-8s %-10s\n", "----", "-----", "-----", "----", "-----"
}

/^[[:space:]]*Job_Owner[[:space:]]*=/ {
    sub(/.*=/, "", $0)
    split($0, a, "@")
    user = a[1]
}

/^[[:space:]]*egroup[[:space:]]*=/ {
    sub(/.*=/, "", $0)
    group = $0
}

/^[[:space:]]*queue[[:space:]]*=/ {
    sub(/.*=/, "", $0)
    queue = $0
}

/^[[:space:]]*Resource_List.ncpus[[:space:]]*=/ {
    sub(/.*=/, "", $0)
    ncpus = $0 + 0

    key = user "|" group "|" queue
    jobs[key]++
    cpus[key] += ncpus

    g_jobs[group]++
    g_cpus[group] += ncpus

    q_cpus[queue] += ncpus
}

END {
    for (k in jobs) {
        split(k, f, "|")
        printf "%-15s %-12s %-10s %-8d %-10d\n",
               f[1], f[2], f[3], jobs[k], cpus[k]
    }

    print "\n=== GROUP SUMMARY ==="
    printf "%-12s %-8s %-10s\n", "GROUP", "JOBS", "NCPUS"
    printf "%-12s %-8s %-10s\n", "-----", "----", "-----"
    for (g in g_jobs) {
        printf "%-12s %-8d %-10d\n", g, g_jobs[g], g_cpus[g]
    }

    print "\n=== QUEUE SUMMARY ==="
    printf "%-10s %-10s\n", "QUEUE", "NCPUS"
    printf "%-10s %-10s\n", "-----", "-----"
    for (q in q_cpus) {
        printf "%-10s %-10d\n", q, q_cpus[q]
    }
}
'
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
