# PBS qstat Monitor

A lightweight Bash tool for monitoring jobs, users, and resource utilization in
PBS-based High Performance Computing (HPC) clusters.

This script is designed to help HPC system administrators and engineers quickly
understand cluster workload, user activity, and scheduler resource usage from a
single command-line report.

---

## Features

- Display current job status using `qstat`
- Count total jobs and jobs per queue
- Identify top users by number of running jobs
- Show waiting (Q) jobs per user
- Provide a detailed per-user scheduler usage summary:
  - Number of jobs
  - Allocated CPUs
  - Allocated nodes
  - Queue distribution (thin, fat, A100, H100)

---

## Sample Output

- Overall job counts
- Top users by job activity
- Waiting queue pressure
- Per-user resource allocation summary sorted by job count

Designed for quick operational insight during daily cluster checks.

---

## Requirements

- PBS / OpenPBS / PBS Pro
- `qstat` command available in PATH
- Bash shell
- CentOS / RHEL-based HPC environments (tested)

---

## Usage

```bash
chmod +x qstat_monitor.sh
./qstat_monitor.sh
