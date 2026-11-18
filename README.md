# Efficiency Lab: Measuring What Kind of Slow

COSI 106B, Fall 2026. About 45 minutes in class.

Three functions do the same job, counting HTTP status codes in a log, and each one leans on a different resource. You'll measure them, then point profilers at one of them and compare what each tool says.

## Files

| File | What it is |
|---|---|
| `workloads.py` | The three workloads you'll measure |
| `server.py` | A small log server on your own machine, for the network workload |
| `measure.py` | A measurement harness: wall time, CPU time, peak memory |
| `run.py` | Runs one workload with no harness around it (used in `EXPLORE.md`) |
| `Makefile` | One short command per step (`make help` lists them) |
| `EXPLORE.md` | Extra things to try after class |

## Setup (before class)

You need Docker Desktop running, as for the homeworks.

1. Clone the repository:
   ```
   git clone https://github.com/brandeis-cosi-106b/perf_demo.git
   ```
2. Open the `perf_demo` folder in VS Code and choose **Reopen in Container** when asked (or run "Dev Containers: Reopen in Container" from the command palette). The lab uses the same image as HW5, so if you have HW5 set up there is nothing new to download.
3. In the VS Code terminal, run:
   ```
   make measure
   ```
   If you see a table with four rows, you're set.

Every tool is already installed in the container. You don't need to install anything with `pip` or `uv`.

## 1. Predict (3 min)

Read `cpu_workload`, `network_workload`, and `memory_workload` in `workloads.py`. Don't run anything yet.

For each one, write down which resource you think it spends the most: CPU, waiting, or memory.

## 2. Measure (5 min)

```
make measure
```

This starts the log server, runs every workload once, and prints a table. `CPU/Wall` is the share of the wall-clock time the process spent computing.

**Turn to a neighbor:** which of your predictions did the table get wrong?

## 3. The chart (at the front, 4 min)

The instructor will put up a chart of the same numbers.

## 4. Which function? (6 min)

```
make cprofile
```

cProfile is built into Python. It records every function call while `measure.py` runs the memory workload, then prints the 8 functions with the most `tottime` (time inside the function itself, not counting the functions it calls).

**Turn to a neighbor:** cProfile names a function. Which line inside `memory_workload` would you change first to lower its memory?

## 5. Which line? (10 min)

Make the terminal panel as wide as you can first (drag its edge, or maximize it). memray's tree needs the room.

```
make memray
```

memray records every allocation while `measure.py` runs the memory workload. It prints its top 5 locations by size, then opens a tree of what was in memory at the peak. Find the lines from `workloads.py` in the tree (the arrow keys move around it). Press `q` to quit.

**Turn to a neighbor:** memray's top 5 and its tree point to different lines in `memory_workload`. If your job were to lower peak memory, which line would you change?

## 6. Another profiler, and an AI optimizer (at the front, 10 min)

The instructor will run a different profiler, scalene, on all the workloads, then use its built-in AI optimizer on `memory_workload` with a model running on the laptop.

## 7. Close (7 min)

`measure.py` counts time and memory. What does it treat as not a problem?

## After class

`EXPLORE.md` has the pieces we didn't have time for. Each one says what to run and what to look at.

## Quick reference

| Command | What it does |
|---|---|
| `make measure` | All workloads: wall time, CPU time, peak memory |
| `make cprofile` | cProfile on the memory workload |
| `make memray` | memray on the memory workload (press `q` to leave the tree) |
| `make server` | Run the log server yourself, in its own terminal |
| `make clean` | Remove the profile files |
| `python measure.py cpu` (or `memory`, `network`) | One workload (`network` needs the server running) |
