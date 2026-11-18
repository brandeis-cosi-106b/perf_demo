"""
Run one workload with nothing measuring it, so a profiler sees only the workload.

Usage:
  python run.py memory
  python run.py cpu
"""

import sys

from workloads import cpu_workload, generate_logs, memory_workload

WORKLOADS = {"cpu": cpu_workload, "memory": memory_workload}

if __name__ == "__main__":
    name = sys.argv[1] if len(sys.argv) > 1 else "memory"
    WORKLOADS[name](generate_logs())
