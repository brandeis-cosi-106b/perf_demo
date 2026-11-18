# Exploring further

Things we didn't have time for in class. They're optional and in no particular order. Each one says what to run and what to look at; working out what it means is up to you.

## The network rows' memory

In `make measure`, look at the `Peak mem` column for the two network rows.

In `measure.py`, find `run_network` and swap its two `rows.append(...)` lines, so the fast endpoint runs first. Run `make measure` again and look at the same column.

What decides which row gets the larger number? (Undo the swap when you're done: `git checkout measure.py`.)

## Measuring changes what you measure

`make cprofile` and `make memray` both print `measure.py`'s own table before the profiler's report. Compare their `memory_workload` rows with the one from `make measure`.

## The harness inside the profile

`make memray` profiles `measure.py`, which runs its own memory measurement (tracemalloc) around the workload. `run.py` runs the same workload with nothing around it:

```
memray run -q --trace-python-allocators -fo bare.bin run.py memory
memray tree bare.bin
```

Compare the size memray gives line 65 here with the size in `make memray`'s tree. Which of the two is closer to the `Peak mem` that `make measure` reports for `memory_workload`?

## The CPU workload under cProfile

```
python -m cProfile -s tottime measure.py cpu
```

Find `cpu_workload` and compare its `tottime` with `memory_workload`'s from `make cprofile`.

## Waiting in parallel

Rewrite `network_workload` so it sends its 12 requests at the same time, using `concurrent.futures.ThreadPoolExecutor`. Then run `make measure` again. Which columns change for the slow endpoint, and which stay the same?

## The chart yourself

The chart from class comes from `visualize.py`. It needs matplotlib, which the container leaves out:

```
uv pip install matplotlib
make server
```

Then, in a second terminal:

```
python visualize.py
```

It writes `metrics.png`; open it from the VS Code file list.

## More questions

- `measure.py` finds which workload is slow, cProfile which function, memray which line. What might tools this specific extend in the developer who uses them, and what might they wear down? (McLuhan)
- Where do you see Ellul's argument in how engineers talk about performance?
- If a manager asked you to "make this code more efficient," what's the first question you'd ask back?
