# Exercise 07 — comm

**Goal:** compare two sorted files line by line and isolate what's unique to each, or common to both — in one pass.

## Setup

```bash
cd demo
```

The demo provides two sorted capability lists: `data/capabilities-a.txt` and `data/capabilities-b.txt`.

## Default output — three columns

```bash
comm data/capabilities-a.txt data/capabilities-b.txt
```

```
                code-generation        ← in both
                document-qa
        embeddings                     ← only in B
                function-calling
        image-generation               ← only in B
                json-mode
...
code-generation   ← only in A (none in this case)
```

Column 1: only in file A. Column 2: only in file B. Column 3: in both.

## Suppress columns you don't need

```bash
# Only in A (not in B):
comm -23 data/capabilities-a.txt data/capabilities-b.txt

# Only in B (not in A):
comm -13 data/capabilities-a.txt data/capabilities-b.txt

# In both:
comm -12 data/capabilities-a.txt data/capabilities-b.txt
```

`-1` suppresses column 1, `-2` suppresses column 2, `-3` suppresses column 3.

## Compare two model output lists

```bash
# Simulate two runs of the same prompt returning different top words
echo -e "attention\nbatch\ncontext\nembedding\ntoken" | sort > /tmp/run-a.txt
echo -e "attention\ncache\ncontext\nlatency\ntoken" | sort > /tmp/run-b.txt

echo "=== only in run A ==="
comm -23 /tmp/run-a.txt /tmp/run-b.txt

echo "=== only in run B ==="
comm -13 /tmp/run-a.txt /tmp/run-b.txt

echo "=== consistent across both ==="
comm -12 /tmp/run-a.txt /tmp/run-b.txt
```

## Compare two dependency lockfiles

```bash
# Check what packages were added or removed between two lock snapshots
comm -23 <(sort /tmp/lock-old.txt) <(sort /tmp/lock-new.txt)  # removed
comm -13 <(sort /tmp/lock-old.txt) <(sort /tmp/lock-new.txt)  # added
```

Process substitution (`<(...)`) lets you sort on the fly without temp files.

## The insight

`comm` replaces the `diff | grep '^[<>]'` pattern with explicit, named outputs. When comparing two model runs, two prompt lists, two tool sets, or any two sorted datasets, `comm` gives you three clean columns with no noise. The key requirement: both inputs must be sorted — use `sort` or process substitution if they aren't.
