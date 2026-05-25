#!/usr/bin/env bash
# linux-archaeology-lab setup
# Creates demo/ with sample data for all 10 exercises.
# Run once. Then open exercises/ and follow along.
set -euo pipefail

DEMO="demo"

if [ -d "$DEMO" ]; then
  echo "⚠  $DEMO already exists. Remove it first: rm -rf $DEMO"
  exit 1
fi

# ── dependency check ─────────────────────────────────────────────────────────
echo "Checking dependencies..."
MISSING=()
for cmd in watch tee column comm tac pv ts sponge vidir parallel; do
  command -v "$cmd" &>/dev/null || MISSING+=("$cmd")
done

if [ ${#MISSING[@]} -gt 0 ]; then
  echo ""
  echo "Missing commands: ${MISSING[*]}"
  echo "Install with:"
  echo "  sudo apt install pv moreutils parallel"
  echo "  # or on macOS:"
  echo "  brew install pv moreutils parallel"
  echo ""
  read -r -p "Continue anyway? [y/N] " yn
  [[ "$yn" =~ ^[Yy]$ ]] || exit 1
fi

mkdir -p "$DEMO"/{logs,data,outputs,queue,batch}

# ── sample data for column / comm / tac ──────────────────────────────────────
cat > "$DEMO/data/models.tsv" << 'EOF'
model	provider	params	context_k	license
llama-3.1-8b	Meta	8B	128	Llama 3
llama-3.1-70b	Meta	70B	128	Llama 3
mistral-7b	Mistral AI	7B	32	Apache 2.0
mixtral-8x7b	Mistral AI	47B	64	Apache 2.0
gemma-2-9b	Google	9B	8	Gemma
phi-3-mini	Microsoft	3.8B	128	MIT
qwen2-7b	Alibaba	7B	128	Apache 2.0
deepseek-r1	DeepSeek	671B	64	MIT
claude-3-haiku	Anthropic	–	200	Commercial
gpt-4o-mini	OpenAI	–	128	Commercial
EOF

cat > "$DEMO/data/capabilities-a.txt" << 'EOF'
code-generation
document-qa
function-calling
image-understanding
json-mode
long-context
math-reasoning
multilingual
streaming
summarization
EOF

cat > "$DEMO/data/capabilities-b.txt" << 'EOF'
code-generation
document-qa
embeddings
function-calling
image-generation
json-mode
long-context
math-reasoning
rag-retrieval
streaming
summarization
EOF

# ── agent log for ts / tac / watch ───────────────────────────────────────────
cat > "$DEMO/logs/agent.log" << 'EOF'
[INFO] Agent initialising
[INFO] Loading tool registry
[INFO] Connected to MCP server: filesystem
[INFO] Connected to MCP server: search
[INFO] Received task: summarise Q3 sales report
[INFO] Planning: 3 steps identified
[INFO] Step 1/3: read_file sales-q3.pdf
[WARN] File exceeds context limit — chunking into 4 parts
[INFO] Step 1/3: complete (4 chunks, 12 400 tokens)
[INFO] Step 2/3: web_search recent industry benchmarks
[INFO] Step 2/3: complete (8 results retrieved)
[INFO] Step 3/3: synthesise and write summary
[INFO] Step 3/3: complete (847 tokens generated)
[INFO] Task complete
EOF

# ── queue files for watch / inotifywait patterns ─────────────────────────────
for i in $(seq 1 5); do
  echo "job-$i: pending" > "$DEMO/queue/job-$i.txt"
done

# ── large synthetic dataset for pv ───────────────────────────────────────────
python3 - << 'PYEOF'
import json, random, pathlib
words = ["inference","latency","throughput","token","context","embedding",
         "retrieval","generation","prompt","completion","sampling","temperature"]
out = pathlib.Path("demo/data/prompts.jsonl")
with out.open("w") as f:
    for i in range(2000):
        obj = {"id": i, "prompt": " ".join(random.choices(words, k=12)),
               "max_tokens": random.choice([256, 512, 1024])}
        f.write(json.dumps(obj) + "\n")
print(f"  wrote {out} ({out.stat().st_size // 1024} KB)")
PYEOF

# ── batch scripts for parallel ────────────────────────────────────────────────
for topic in "vector databases" "attention mechanisms" "RLHF" "RAG pipelines" "model quantization"; do
  slug=$(echo "$topic" | tr ' ' '-')
  echo "echo \"[summarising: $topic]\"; sleep 0.$((RANDOM % 9 + 1)); echo \"done: $topic\"" \
    > "$DEMO/batch/summarise-${slug}.sh"
  chmod +x "$DEMO/batch/summarise-${slug}.sh"
done

# ── sponge demo file ─────────────────────────────────────────────────────────
cat > "$DEMO/data/raw-output.txt" << 'EOF'

   excess   whitespace   here

multiple
blank


lines

trailing spaces
EOF

echo ""
echo "✓  demo/ created"
echo ""
echo "Contents:"
find demo -type f | sort
echo ""
echo "Next: open exercises/01-watch.md"
