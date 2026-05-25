# Exercise 09 — vidir

**Goal:** rename or delete a batch of files by editing a directory listing in your text editor — no scripting, no `rename` regex, just edit lines.

## Setup

```bash
cd demo
sudo apt install moreutils   # if not already installed
```

## Open a directory in your editor

```bash
vidir batch/
```

Your `$EDITOR` opens with a numbered list of files:

```
1	batch/summarise-RAG-pipelines.sh
2	batch/summarise-RLHF.sh
3	batch/summarise-attention-mechanisms.sh
4	batch/summarise-model-quantization.sh
5	batch/summarise-vector-databases.sh
```

Rename by editing the path on the right. Delete by removing the line entirely. Save and quit — vidir applies every change atomically.

## Batch rename: strip a prefix

Open `vidir batch/`, then in your editor run a substitute:

```
:%s/summarise-/run-/g
```

Save. All five files are renamed from `summarise-*.sh` to `run-*.sh` with one editor command.

## Move files to a subdirectory

Edit the paths to include a new directory segment:

```
1	batch/archive/run-RAG-pipelines.sh
```

`vidir` creates intermediate directories as needed.

## Delete a subset of files

Remove lines for the files you want to delete. Leave the rest. Save.

## Rename output files after a batch run

```bash
# Simulate a batch that produced numbered outputs
for i in $(seq 1 5); do echo "result" > outputs/output-$i.txt; done

vidir outputs/
# In editor: rename output-1.txt → summary-rag.txt, etc.
```

## The insight

`vidir` turns a bulk file rename into a text editing problem — a domain where you already have powerful tools (regex substitution, macros, multicursor). It replaces `rename 's/old/new/' *`, which requires remembering Perl regex syntax, and `for f in *; do mv "$f" ...; done` loops, which require careful quoting. If you can edit text, you can bulk-rename files.
