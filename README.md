# linux-archaeology-lab

[![Tip my tokens](https://tokentip.to/badge/copyleftdev.svg?logo=1)](https://tokentip.to/@copyleftdev)

A companion repo for **"The Linux Commands You Forgot Exist"**.

These aren't obscure one-liners for their own sake. They're pipe-and-stream primitives that were built before "AI workflow" was a phrase — and are more useful now than ever: timestamping agent logs, watching GPU memory, getting a progress bar on a 2000-row JSONL inference run, comparing two model output sets in one command.

---

## Quick start

```bash
git clone https://github.com/copyleftdev/linux-archaeology-lab
cd linux-archaeology-lab
bash setup.sh
```

**Dependencies** (setup.sh will warn if missing):

```bash
sudo apt install pv moreutils parallel
# macOS:
brew install pv moreutils parallel
```

`setup.sh` takes about 5 seconds. It creates `demo/` with log files, JSONL datasets, TSV tables, and batch scripts — everything the exercises need.

---

## Exercises

| # | Command | What you'll do |
|---|---------|---------------|
| [01](exercises/01-watch.md) | `watch` | Monitor GPU memory, queue depth, or any live metric |
| [02](exercises/02-tee.md) | `tee` | Pipe LLM output to terminal AND a log file simultaneously |
| [03](exercises/03-pv.md) | `pv` | Add a progress bar and ETA to any pipeline |
| [04](exercises/04-ts.md) | `ts` | Timestamp every line of an agent's output |
| [05](exercises/05-sponge.md) | `sponge` | Transform a file in-place safely without a temp file |
| [06](exercises/06-column.md) | `column` | Format raw text into aligned tables in one flag |
| [07](exercises/07-comm.md) | `comm` | Find what's unique to each of two lists, and what's shared |
| [08](exercises/08-tac.md) | `tac` | Read a log newest-first; find last occurrence of a pattern |
| [09](exercises/09-vidir.md) | `vidir` | Batch-rename files using your text editor's full power |
| [10](exercises/10-parallel.md) | `parallel` | Run concurrent tasks with job control, retries, and ordered output |

---

## Claude Code skill

The repo ships `.claude/skills/linux-archaeology.md` — a reasoning skill that maps natural-language problem descriptions to the right command. Open the repo in Claude Code and describe your problem in plain English:

> *"I need a progress bar for this pipeline"* → `pv`  
> *"How do I timestamp my agent logs?"* → `ts`  
> *"I want to rename a batch of files without scripting"* → `vidir`

Install the skill in any of your own projects:

```bash
mkdir -p .claude/skills
curl -sL https://raw.githubusercontent.com/copyleftdev/linux-archaeology-lab/main/.claude/skills/linux-archaeology.md \
  > .claude/skills/linux-archaeology.md
```

---

## Reset

```bash
rm -rf demo/
bash setup.sh
```

---

## Related

- Article: [The Linux Commands You Forgot Exist](https://dev.to/copyleftdev/linux-commands-you-forgot-exist)
- Sister repo: [git-archaeology-lab](https://github.com/copyleftdev/git-archaeology-lab)
- Issues and PRs welcome — especially if a step behaves differently on macOS or older distros.
