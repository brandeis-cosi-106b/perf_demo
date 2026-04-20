# Efficiency Lab — Automated Performance Measurement

**Course:** Automation in Software Development  
**Time:** ~50 minutes  

---

## What this lab is about

Three versions of the same program — parsing synthetic HTTP access logs — each stress a different resource. You'll measure all three automatically and compare the numbers. The goal is not to make everything faster; it's to understand *what kind of slow* each program is, and to notice that the measurement tools are themselves a form of automation.

---

## Files

| File | Purpose |
|---|---|
| `workloads.py` | Three log-analysis workloads |
| `server.py` | Localhost HTTP server (needed for the network workload) |
| `measure.py` | Automated measurement harness |
| `visualize.py` | Generates a comparison chart |

---

## Setup (~5 min)

**1.** Install [uv](https://docs.astral.sh/uv/) if you don't have it:

```
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**2.** Install dependencies (creates a local `.venv` automatically):

```
uv sync
```

**3.** In a **second terminal**, start the localhost server:

```
uv run python3 server.py
```

You should see: `Server listening on http://127.0.0.1:5001`  
Leave this terminal open for the rest of the lab.

---

## Part 1 — CPU-Bound Work (~10 min)

Read `cpu_workload()` in `workloads.py`. It parses 20,000 log lines with a regular expression and counts requests by HTTP status code.

Before running anything: **predict** — will CPU time be close to wall-clock time, or far apart?

Run it:

```
uv run python3 measure.py cpu
```

You'll see three numbers: wall-clock time, CPU time, and their ratio.

**Discuss:**
- Why are CPU time and wall time nearly equal here?
- If you wanted this to run faster, what would you change — the algorithm, the data structure, or something else?

---

## Part 2 — I/O-Bound (Network) Work (~12 min)

Read `network_workload()` in `workloads.py`. It makes 12 HTTP requests to `localhost:5001/logs`. Each request returns 100 log lines, but the server adds a **150 ms artificial delay** per request.

Predict: will CPU time be close to wall time here?

Run it (server must be running):

```
uv run python3 measure.py network
```

You'll see two rows — the slow endpoint and the fast one (no delay).

**Discuss:**
- Wall time is much larger than CPU time for the slow endpoint. What is the process doing during the gap?
- The fast endpoint doesn't change the code — only the server delay disappears. What does that tell you about where the bottleneck was?
- Could you reduce wall time for the slow endpoint without modifying `server.py`? How?

---

## Part 3 — Memory-Heavy Work (~8 min)

Read `memory_workload()` in `workloads.py` side by side with `cpu_workload()`. Both process the same 20,000 lines and return the same result.

Predict: which uses more peak memory, and by how much?

Run it:

```
uv run python3 measure.py memory
```

**Discuss:**
- Find the specific line(s) in `memory_workload` that explain the higher memory usage.
- The outputs are identical. If the outputs are the same, why does the implementation matter?
- What happens to each workload if the dataset is 10× larger?

---

## Part 4 — Automated Measurement (~12 min)

Run the full harness and generate the chart:

```
uv run python3 measure.py
uv run python3 visualize.py
```

The left panel shows how much of wall time was actual CPU work vs waiting. The right panel shows peak memory. That large gray bar for the network workload — all that waiting — was completely invisible until we instrumented it. The tooling didn't change what the code does; it changed what we could see.

Most performance advice you'll find online assumes the bottleneck is CPU. These numbers suggest it usually isn't.

**Discuss:**
- Label each workload: CPU-bound, I/O-bound, or memory-bound. What single number in the table tells you?
- Without `measure.py`, how would you compare these three? What would you risk getting wrong?

### From "which workload?" to "which line?"

`measure.py` told you which workload is slow. `cProfile` (built into Python) tells you which function inside it costs the most.

```
uv run python3 -m cProfile -s tottime measure.py cpu
```

The output has a lot of Python internals noise. Scroll past it and find the lines mentioning `workloads.py`. Look at the `tottime` column — time spent *inside* that function, not counting anything it calls.

Now the same for the memory workload:

```
uv run python3 -m cProfile -s tottime measure.py memory
```

Find `workloads.py` again. How does `memory_workload`'s `tottime` compare to `cpu_workload`'s? That number is actionable — it tells you exactly which function to rewrite.

*(Optional — requires `uv sync --extra profiler`)* Scalene goes one level further: a per-line breakdown of CPU *and* memory allocation simultaneously.

```
uv run scalene run --cli measure.py
```

Find `workloads.py` in the Scalene output. Look for lines with non-zero values in the Memory column. Scalene doesn't just tell you which function — it shows you which specific line is doing the allocating.

**Discuss:**
- `measure.py` → which workload. `cProfile` → which function. Scalene → which line. Each layer narrows the gap between "something is slow" and "change this exact thing." There's a McLuhan-ish question here: what might these increasingly specific tools be extending in the developer who uses them — and what might they be atrophying?

---

## Part 5 — Reflection (~10 min)

Pick a few of these — you won't get to all of them.

- For the network workload, the bottleneck is entirely inside the server — not in your code at all. Does it make sense to "optimize" this workload? Who actually owns the problem?
- `measure.py` measures wall time, CPU time, and memory. It doesn't measure energy use, developer comprehension time, or anything involving a human. The choice of what to instrument is a value judgment — it decides what counts as a problem. What does `measure.py` treat as not a problem?
- Could a program score well on all three metrics and still be a bad program? Describe one.
- Ellul argued in *The Technological Society* that technique tends to pursue efficiency as an end in itself, regardless of whether efficiency serves human purposes. Do you see that tendency in how engineers talk about performance?
- If a manager asked you to "make this code more efficient," what's the first question you'd ask back?

---

## Quick reference

| Command | What it does |
|---|---|
| `uv sync` | Install dependencies (matplotlib; run once) |
| `uv sync --extra profiler` | Also install Scalene |
| `uv run python3 server.py` | Start the localhost server (separate terminal) |
| `uv run python3 measure.py [cpu\|network\|memory]` | Run one workload |
| `uv run python3 measure.py` | Run all workloads |
| `uv run python3 visualize.py` | Generate `metrics.png` |
| `uv run python3 visualize.py --no-network` | Skip network workload |
| `uv run scalene run --cli measure.py` | Line-level profiler (optional) |
