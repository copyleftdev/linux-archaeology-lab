# Exercise 02 — tee

**Goal:** send one stream of output to two destinations at once — the terminal and a file — without buffering or losing data.

## Setup

```bash
cd demo
```

## Basic split

```bash
cat logs/agent.log | tee outputs/agent-copy.log
```

The log prints to the terminal *and* lands in `outputs/agent-copy.log` simultaneously. No waiting for the command to finish.

## Append instead of overwrite

```bash
echo "new event" | tee -a logs/agent.log
```

`-a` appends. Without it, `tee` truncates the file on open.

## Fan out to multiple files

```bash
cat data/models.tsv | tee outputs/models-backup.tsv outputs/models-audit.tsv > /dev/null
```

Three destinations (two files, plus stdout suppressed with `/dev/null`). Any number of filenames accepted.

## The AI workflow pattern

Pipe an LLM's stdout to the terminal for live reading *and* to a log file for later analysis — in one command:

```bash
# Pattern (substitute your actual tool):
llm-cli generate "summarise the Q3 report" | tee outputs/summary.txt

# With timestamps (combine with ts — see exercise 04):
llm-cli generate "summarise the Q3 report" | ts '[%H:%M:%S]' | tee outputs/summary-timestamped.txt
```

## Process and log simultaneously

```bash
cat data/prompts.jsonl \
  | tee outputs/prompts-raw.jsonl \
  | python3 -c "
import sys, json
for line in sys.stdin:
    obj = json.loads(line)
    print(obj['id'], obj['prompt'][:40])
" | tee outputs/prompts-preview.txt | wc -l
```

Three outputs: the raw JSONL copy, the preview table, and the line count — all from one pipeline pass.

## The insight

`tee` is the correct answer to "I want to pipe this through a transform but also keep the original." It replaces the pattern of running a command twice (once to see, once to save), which doubles your work and risks different results if the source is non-deterministic.
