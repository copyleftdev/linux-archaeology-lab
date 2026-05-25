# Exercise 08 — tac

**Goal:** reverse the line order of any input — the simplest way to read a log most-recent-first.

## Setup

```bash
cd demo
```

## Basic reversal

```bash
tac logs/agent.log
```

The last line of the log is now the first. No temp files, no `tail` gymnastics.

## The log-reading pattern

```bash
# See the last 5 events first, with context:
tac logs/agent.log | head -5
```

Compare to the common alternative:
```bash
tail -5 logs/agent.log   # same result, but:
tail -f logs/agent.log   # follow mode — for live tailing, tail -f is still the right tool
```

`tac` wins when you want to *process* lines in reverse — filter, transform, pipe further.

## Find the last occurrence of a pattern

```bash
# Last WARNING in the log:
tac logs/agent.log | grep -m1 WARN
```

`-m1` stops after the first match — which is the *last* occurrence in the original file.

## Reverse a JSONL file for newest-first processing

```bash
tac data/prompts.jsonl | head -5 | python3 -c "
import sys, json
for line in sys.stdin:
    obj = json.loads(line)
    print(f\"id={obj['id']}  prompt={obj['prompt'][:50]}\")
"
```

## Build a reverse-ordered report

```bash
echo "=== Recent agent events (newest first) ==="
tac logs/agent.log | column -t -s ' '
```

## Combine with ts for a reverse timestamped log

```bash
# Generate a timestamped log first:
cat logs/agent.log | ts '[%H:%M:%S]' > outputs/agent-timed.log

# Read it newest-first:
tac outputs/agent-timed.log | head -5
```

## The insight

`tac` is `cat` spelled backwards and does exactly what that implies. It's a one-word answer to "I want to process this log from the end." Anything you can do with `cat file | cmd`, you can do reversed with `tac file | cmd`. No awk, no Python, no `sort -r` on structured data that can't be meaningfully sorted.
