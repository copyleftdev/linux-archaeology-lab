# Exercise 10 — parallel (GNU parallel)

**Goal:** run many independent shell commands concurrently — with built-in job control, retries, and output ordering — in one line.

## Setup

```bash
cd demo
sudo apt install parallel   # if not already installed
```

## Basic parallel execution

```bash
ls batch/*.sh | parallel bash {}
```

All five batch scripts run simultaneously. `{}` is the placeholder for the input line.

## Control concurrency

```bash
ls batch/*.sh | parallel -j2 bash {}
```

`-j2` runs at most 2 jobs at a time. `-j0` uses one slot per CPU core.

## Keep output ordered and labeled

```bash
ls batch/*.sh | parallel --tag bash {}
```

`--tag` prefixes each output line with the input that produced it — no interleaving confusion.

## Run inference over a JSONL file

```bash
# Simulate: extract prompts, run N in parallel, collect outputs
head -20 data/prompts.jsonl \
  | parallel -j4 --pipe --block 1k \
    'python3 -c "
import sys, json
for line in sys.stdin:
    obj = json.loads(line)
    print(json.dumps({\"id\": obj[\"id\"], \"result\": \"processed\"}))
"' \
  | tee outputs/parallel-results.jsonl \
  | wc -l
```

`--pipe` feeds stdin to each job as a block rather than line by line — good for batched inference.

## Retry failed jobs

```bash
ls batch/*.sh | parallel --retries 3 bash {}
```

Re-runs any job that exits non-zero, up to 3 times.

## Dry run — see what would execute

```bash
ls batch/*.sh | parallel --dry-run bash {}
```

Prints the commands without running them.

## Progress bar

```bash
ls batch/*.sh | parallel --progress bash {}
```

Shows a live count of completed / running / remaining jobs.

## The insight

`parallel` is `xargs -P` with sane defaults and readable syntax. For AI workloads — running the same prompt against multiple models, processing a JSONL dataset in chunks, calling an API endpoint for each item in a list — it turns a sequential loop into concurrent execution in one command, with no threading code, no async boilerplate, and output you can actually read.
