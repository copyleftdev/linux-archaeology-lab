# Exercise 06 — column

**Goal:** format delimiter-separated stdin into a readable aligned table — no spreadsheet, no awk, one flag.

## Setup

```bash
cd demo
```

## Align a TSV file

```bash
column -t -s $'\t' data/models.tsv
```

`-t` enables table mode. `-s $'\t'` sets the delimiter to tab. Every column aligns automatically to the widest value.

Before:
```
model	provider	params	context_k	license
llama-3.1-8b	Meta	8B	128	Llama 3
```

After:
```
model          provider      params  context_k  license
llama-3.1-8b   Meta          8B      128        Llama 3
```

## Align CSV output from a command

```bash
echo "name,size,modified" > /tmp/header.csv
find data/ -type f -printf "%f,%s,%TY-%Tm-%Td\n" | sort >> /tmp/header.csv
column -t -s ',' /tmp/header.csv
```

## Wrap long lists into columns

```bash
cat data/capabilities-a.txt | column
```

`column` without `-t` wraps the input into multiple screen-width columns — like `ls` does automatically.

## Format agent tool call output

LLM tool call results often come back as raw key:value pairs. `column` makes them scannable:

```bash
cat << 'EOF' | column -t -s ':'
tool:web_search
status:success
results:8
latency_ms:342
tokens_used:1204
cost_usd:0.0024
EOF
```

## Pipe watch + column for a live table

```bash
watch -n2 'column -t -s $'"'"'\t'"'"' data/models.tsv'
```

A refreshing aligned table view of any TSV — no TUI library required.

## The insight

`column` is the missing piece between a command that emits structured text and a human who needs to read it. In AI workflows it turns raw model comparison data, tool call logs, and benchmark results into scannable tables in one pipeline stage — no Python, no pandas, no formatting code.
