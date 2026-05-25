# Exercise 05 — sponge

**Goal:** buffer all of stdin before writing to a file — making in-place pipeline transforms safe.

## Setup

```bash
cd demo
sudo apt install moreutils   # if not already installed
```

## The problem sponge solves

This destroys the file before `sort` reads it:

```bash
sort data/capabilities-a.txt > data/capabilities-a.txt  # ⚠ race: truncates on open
cat data/capabilities-a.txt  # empty
```

The shell opens the output file for writing (and truncates it) before the left-hand command even starts. `sponge` fixes this by reading all of stdin into memory first, then writing.

## Safe in-place sort

```bash
sort data/capabilities-a.txt | sponge data/capabilities-a.txt
cat data/capabilities-a.txt   # sorted, intact
```

`sponge` soaks up the entire stream, waits for EOF, then writes atomically.

## In-place JSON formatting

```bash
# create a compact JSON file
echo '{"model":"llama-3.1-8b","params":"8B","context":128}' > outputs/model.json

# format it in-place safely
python3 -m json.tool outputs/model.json | sponge outputs/model.json
cat outputs/model.json
```

## Clean up the raw output file in-place

```bash
cat data/raw-output.txt         # messy whitespace, blank lines

# strip leading/trailing blank lines and squeeze multiple blanks into one
cat data/raw-output.txt \
  | sed '/./,/^$/!d' \
  | cat -s \
  | sponge data/raw-output.txt

cat data/raw-output.txt         # cleaned
```

## In-place JSONL deduplication

```bash
# duplicate a few lines to create a dirty file
cat data/prompts.jsonl data/prompts.jsonl | head -20 > outputs/dirty.jsonl

# deduplicate in-place
sort -u outputs/dirty.jsonl | sponge outputs/dirty.jsonl
wc -l outputs/dirty.jsonl   # half the lines
```

## The insight

Any time a pipeline reads from and writes to the same file, you need `sponge`. It's the safe alternative to a temporary file (`cmd file > tmp && mv tmp file`), collapsed into one word. Indispensable for in-place transforms on model outputs, config files, and JSONL datasets.
