# linux-archaeology

Reason through shell pipeline problems and surface the right forgotten Linux command. Each section maps a real situation to a specific tool with concrete invocations.

## TRIGGER

Invoke this skill when the user:

- Wants to monitor a running process, file, or resource without modifying the process
- Needs to send output to both the screen and a file at the same time
- Is running a slow pipeline or batch job and has no visibility into progress
- Wants every log line to carry a timestamp without changing the program being logged
- Needs to transform a file in-place using a pipeline (read and write the same file)
- Wants to format raw text output into a readable aligned table
- Needs to find what's unique to one dataset vs another, or what's shared between two
- Wants to read or process a log or file from the end (newest-first)
- Needs to rename or reorganise a batch of files without writing a script
- Wants to run many independent tasks concurrently without threading code

Also trigger on natural-language descriptions: "how do I watch a file change?", "can I log to a file and see output at the same time?", "I want a progress bar for this pipeline", "how do I timestamp my agent's logs?", "I need to sort a file in-place without a temp file", "how do I line up these columns?", "what's the difference between these two lists?", "how do I read the log bottom-up?", "can I rename a bunch of files at once?", "how do I run these in parallel?".

---

## Reasoning chains

---

### 1. Monitor something while it runs

**Ask:** Are you watching a file, a command output, or a system resource that changes over time?

**Yes — want a refreshing terminal view:**
```bash
watch -n<seconds> <command>

# examples:
watch -n1 nvidia-smi --query-gpu=memory.used --format=csv
watch -n2 'ls -lh outputs/ | tail -20'
watch -n1 -d free -h     # -d highlights what changed
```

**Yes — want to follow a growing log file:**
```bash
tail -f <logfile>                           # live stream, no refresh overhead
tail -f <logfile> | ts '[%H:%M:%S]'        # with timestamps (see section 4)
```

`watch` is for commands you re-run; `tail -f` is for files being appended to.

---

### 2. Write output to a file AND see it live

**Ask:** Do you need the output in a file for later AND visible in the terminal now?

**Yes:**
```bash
<command> | tee <output-file>

# append instead of overwrite:
<command> | tee -a <output-file>

# fan out to multiple files:
<command> | tee file1 file2 > /dev/null

# common AI pattern — log and timestamp simultaneously:
<command> 2>&1 | ts '[%H:%M:%S]' | tee run-$(date +%Y%m%d-%H%M%S).log
```

---

### 3. See progress for a slow pipeline

**Ask:** Is there a pipeline step where data flows through and you have no visibility?

**Yes — bytes or throughput:**
```bash
pv <input-file> | <processing-command>
<command> | pv | <next-command>
```

**Yes — line count matters more than bytes:**
```bash
pv --line-mode <input-file> | <processing-command>

# with known total for accurate ETA:
LINES=$(wc -l < input.jsonl)
pv --line-mode --size "$LINES" input.jsonl | <processing-command>
```

**Yes — rate-limit a fast producer for a slow consumer:**
```bash
pv --rate-limit <bytes-per-second> <input-file> | <slow-consumer>
```

---

### 4. Timestamp every line of output

**Ask:** Do you need to know when each line of a log or stream was produced?

**Yes — wall clock timestamp:**
```bash
<command> 2>&1 | ts '[%Y-%m-%dT%H:%M:%S]'

# custom strftime format:
<command> | ts '[%H:%M:%S]'
```

**Yes — time between lines (find where time was spent):**
```bash
<command> | ts -s '%.s'
```

**Yes — timestamp and save:**
```bash
<command> 2>&1 | ts '[%H:%M:%S]' | tee run.log
```

---

### 5. Transform a file in-place with a pipeline

**Ask:** Does your pipeline read from and write to the same file?

**Yes:**
```bash
<transform> <file> | sponge <file>

# examples:
sort data.txt | sponge data.txt
python3 -m json.tool config.json | sponge config.json
grep -v 'DEBUG' app.log | sponge app.log
```

**Do NOT use** `<transform> file > file` — the shell truncates the output file before the input is read.

---

### 6. Format text into an aligned table

**Ask:** Is the input delimited (tabs, commas, spaces, colons) and hard to read unformatted?

**Yes — TSV:**
```bash
column -t -s $'\t' <file>
<command> | column -t -s $'\t'
```

**Yes — CSV:**
```bash
column -t -s ',' <file>
```

**Yes — colon-separated (like /etc/passwd):**
```bash
column -t -s ':' /etc/passwd
```

**Yes — wrap a long list into screen-width columns:**
```bash
<command> | column
```

---

### 7. Compare two lists — find differences and overlap

**Ask:** Do you have two sets of items (sorted files, output lists, capability sets) to compare?

**Prerequisite:** both files must be sorted. If not: `sort file | sponge file` first, or use process substitution.

```bash
# only in file A:
comm -23 a.txt b.txt

# only in file B:
comm -13 a.txt b.txt

# in both:
comm -12 a.txt b.txt

# on-the-fly sorting:
comm -23 <(sort a.txt) <(sort b.txt)
```

---

### 8. Read or process from the end of a file

**Ask:** Do you want to see the most recent entries first, or process a file in reverse line order?

**Yes — read newest-first:**
```bash
tac <logfile> | head -20
```

**Yes — find last occurrence of a pattern:**
```bash
tac <logfile> | grep -m1 'ERROR'
```

**Yes — process each line in reverse order through a pipeline:**
```bash
tac <file> | <pipeline>
```

Use `tail -f` for live streaming. Use `tac` when you want to reverse a complete file for processing.

---

### 9. Rename or reorganise a batch of files

**Ask:** Do you need to rename, move, or delete many files based on their names?

**Yes — interactive rename in your editor:**
```bash
vidir <directory>/

# or specific files:
ls *.txt | vidir -

# inside your editor:
# - edit any path to rename the file
# - delete a line to delete the file
# - change the directory prefix to move the file
# - use editor's regex substitute for bulk patterns: :%s/old/new/g
```

**Simpler case — rename with a fixed pattern:**
```bash
rename 's/old-prefix-/new-prefix-/' *.txt
```

Use `vidir` when the rename logic is complex or varies per file.

---

### 10. Run many tasks concurrently

**Ask:** Do you have a list of independent tasks to run and want them concurrent?

**Yes — simple parallel execution:**
```bash
cat tasks.txt | parallel <command> {}

# from a file list:
ls *.sh | parallel bash {}
```

**Yes — limit concurrency:**
```bash
cat tasks.txt | parallel -j4 <command> {}    # max 4 jobs
cat tasks.txt | parallel -j0 <command> {}    # one per CPU
```

**Yes — keep output ordered and labeled:**
```bash
cat tasks.txt | parallel --tag <command> {}
```

**Yes — retry on failure:**
```bash
cat tasks.txt | parallel --retries 3 <command> {}
```

**Yes — pipe blocks of stdin to each job (batched inference):**
```bash
cat data.jsonl | parallel -j4 --pipe --block 10k <inference-command>
```

---

## Quick reference table

| Situation | Command |
|---|---|
| Monitor a changing command output | `watch -n<s> <cmd>` |
| Output to terminal AND a file | `cmd \| tee file` |
| Progress bar for a pipeline | `pv file \| cmd` or `cmd \| pv \| cmd` |
| Timestamp every output line | `cmd \| ts '[%H:%M:%S]'` |
| In-place file transform | `transform file \| sponge file` |
| Format delimited text as table | `cmd \| column -t -s '<delim>'` |
| Find differences between two lists | `comm -23 a.txt b.txt` |
| Read a log newest-first | `tac logfile \| head -N` |
| Batch rename files in editor | `vidir <dir>/` |
| Run tasks concurrently | `cat tasks.txt \| parallel <cmd> {}` |

---

## Lab

Every scenario above has a working exercise in this repo:

```bash
bash setup.sh      # create demo/ with sample data
# then open exercises/01-watch.md through exercises/10-parallel.md
```
