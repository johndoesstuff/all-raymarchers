import time
import sys
import subprocess

if len(sys.argv) < 2:
    print("Usage: python avgtime.py <command> [args...]")
    sys.exit(1)

cmd = sys.argv[1:]
runs = 1000
times = []

for _ in range(runs):
    start = time.perf_counter()
    subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    end = time.perf_counter()
    times.append(end - start)

average = sum(times) / runs
print(f"Average time over {runs} runs: {average:.6f} seconds")
