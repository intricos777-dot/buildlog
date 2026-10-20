<!-- Watermark: Living_Sin (intricos777-dot) + AI agents (Hermes, Lia, opencode) - collaborative work -->
# buildlog

Durable build/audit journal. Solves one problem: **session transcripts die with the machine.**

Opencode and hermes keep session history in `~/.local/share/` and `~/.hermes/` — wiped on rebuild.
Code survives because it was pushed. This logs the *decisions and fixes* that never made it into a commit message.

## Install

```bash
ln -s ~/Projects/buildlog/buildlog ~/.local/bin/buildlog
```

## Usage

```bash
buildlog build "hermes-agent: makepkg started"
buildlog ok    "126MB pkg built"
buildlog fail  "void-bin: paru stuck cloning Chromium"
buildlog fix   "gtk/settings.ini: bad font family -> Noto Sans fallback"
buildlog env   # snapshot toolchain versions
buildlog tail 40
buildlog push  # push to remote
```

Entries are markdown, one `## <timestamp> · <category>` section each, appended to `logs/buildlog.md`.
Every entry auto-commits, so `git log` is the audit trail.

## Recovering after a rebuild

```bash
git clone <remote> && cd buildlog && buildlog tail 100
```

