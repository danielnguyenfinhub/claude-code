#!/bin/bash
# SessionStart hook for Claude Code on the web.
#
# This repository has no dependency manifests (no package.json / requirements.txt /
# pyproject.toml), no test suite, and no linter configuration. Its executable code is:
#   - TypeScript automation scripts in scripts/ (run with `bun`, no external npm deps)
#   - Python plugin hooks under plugins/ (standard library only)
#
# There is therefore nothing to install. This hook makes the runtimes those scripts
# rely on reliably discoverable for the session and prints a short diagnostic.
#
# It runs in async mode (see the control line below) so the session starts without
# waiting on it. Extend the "Install dependencies" section below if you later add a
# manifest; if that work must finish before the agent runs, consider going synchronous.
set -euo pipefail

# Only run in the remote (Claude Code on the web) environment.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Run asynchronously so the session starts without waiting on this hook.
# (Safe here because there are no dependencies the agent must wait for.)
echo '{"async": true, "asyncTimeout": 300000}'

# --- Ensure the repo's runtimes are on PATH for the whole session ---------------
# bun is installed under ~/.bun/bin, which is not always on PATH in fresh shells.
if [ -d "$HOME/.bun/bin" ] && [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export PATH=\"$HOME/.bun/bin:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi
export PATH="$HOME/.bun/bin:$PATH"

# --- Install dependencies -------------------------------------------------------
# (Nothing to install today — no dependency manifest exists. Add install steps
#  here, e.g. `npm install` or `pip install -r requirements.txt`, if that changes.)

# --- Diagnostic: confirm the toolchain is available -----------------------------
echo "session-start hook: toolchain check"
command -v bun     >/dev/null 2>&1 && echo "  bun:     $(bun --version)"        || echo "  bun:     NOT FOUND"
command -v python3 >/dev/null 2>&1 && echo "  python3: $(python3 --version)"    || echo "  python3: NOT FOUND"
command -v node    >/dev/null 2>&1 && echo "  node:    $(node --version)"       || echo "  node:    NOT FOUND"
echo "session-start hook: done"
