# Efficiency lab. Every target is one short command; `make help` lists them.
# The tools (cProfile, memray) are already installed in the dev container.

.PHONY: help measure server cprofile memray clean

help:
	@echo "make measure    time and memory for all workloads (starts the server for you)"
	@echo "make cprofile   cProfile on the memory workload: time per function"
	@echo "make memray     memray on the memory workload: allocations, then a tree (q quits)"
	@echo "make server     run the log server yourself, in its own terminal"
	@echo "make clean      remove profile files"

# Uses the log server if one is already running (say, from `make server`);
# otherwise starts one for this run and stops it afterwards.
SERVER_UP = python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5001/status', timeout=1)" 2>/dev/null

measure:
	@if $(SERVER_UP); then \
	  python measure.py; \
	else \
	  python server.py & pid=$$!; \
	  for i in 1 2 3 4 5 6 7 8 9 10; do $(SERVER_UP) && break; sleep 0.3; done; \
	  python measure.py; status=$$?; kill $$pid 2>/dev/null; exit $$status; \
	fi

server:
	python server.py

cprofile:
	python -m cProfile -o cprofile.out measure.py memory
	@python -c "import pstats; pstats.Stats('cprofile.out').strip_dirs().sort_stats('tottime').print_stats(8)"

memray:
	memray run -q --trace-python-allocators -fo memray.bin measure.py memory
	@memray stats memray.bin | sed -n '/locations (by size)/,/^$$/p'
	@echo "Opening the tree view. Make the terminal wide, then press q to quit."
	@sleep 2
	memray tree memray.bin

clean:
	rm -f cprofile.out memray.bin bare.bin
