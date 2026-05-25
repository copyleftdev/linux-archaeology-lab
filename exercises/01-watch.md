# Exercise 01 — watch

**Goal:** run any command on a repeating interval and see live-updating output in the terminal.

## Setup

```bash
cd demo
```

## Basic usage

```bash
watch -n2 cat logs/agent.log
```

`-n2` refreshes every 2 seconds. Press `q` or `Ctrl-C` to exit.

## Highlight what changed

```bash
watch -n1 -d ls -lh data/
```

`-d` highlights the diff between the current and previous output — changes flash briefly so you can't miss them.

## Monitor a queue draining

Simulate a queue being processed:

```bash
# terminal 1 — watch the queue
watch -n1 'ls queue/ | wc -l; echo "---"; ls queue/'

# terminal 2 — drain it
for f in queue/*.txt; do sleep 1 && rm "$f"; done
```

The watcher updates as each job disappears.

## Monitor GPU memory during an inference run

```bash
watch -n1 nvidia-smi --query-gpu=memory.used,memory.free --format=csv
```

No `nvidia-smi`? Works identically with any polling command:

```bash
watch -n1 free -h
watch -n2 df -h /
watch -n1 'ps aux | grep python | grep -v grep'
```

## Pipe watch output (--no-title)

`watch` renders a TUI by default. For machine-readable streaming use `--no-title`:

```bash
watch --no-title -n1 date | tee watch-timestamps.log
```

## The insight

`watch` replaces ad-hoc `while true; do cmd; sleep N; done` loops with one flag. In AI workflows it's the simplest way to observe a running agent — monitor its output file, a queue depth, GPU memory, or any file it writes to — without adding any instrumentation to the agent itself.
