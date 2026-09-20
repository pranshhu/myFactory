#!/usr/bin/env bash
# Is this machine ready to run the factory? Prints what is missing and how to get it.
# Exit 1 only when something required is missing. Setup guide: docs/agents/machine-setup.md
bad=0

need() { # need <required|optional> <command> <how to get it>
  if command -v "$2" >/dev/null 2>&1; then
    printf '  ok        %s\n' "$2"
  else
    printf '  MISSING   %-14s %s\n' "$2" "$3"
    [ "$1" = required ] && bad=1
  fi
}

echo "Required"
need required git "apt install git"
need required jq "apt install jq"
need required claude "https://claude.com/claude-code"
need required docker "https://docs.docker.com/engine/install/"
if command -v docker >/dev/null 2>&1; then
  docker compose version >/dev/null 2>&1 || { echo "  MISSING   docker compose  install the compose plugin"; bad=1; }
  docker info >/dev/null 2>&1 || { echo "  PROBLEM   docker          daemon not reachable (is it running, are you in the docker group?)"; bad=1; }
  case "$(command -v docker)" in /snap/*) echo "  note      docker is a snap: it cannot see /tmp or dot-folders directly under \$HOME. Keep projects in a normal folder like ~/code" ;; esac
fi

echo "Builders (without these the orchestrator falls back to the builder subagent)"
need optional agy "Antigravity CLI"
need optional herdr "curl -fsSL https://herdr.dev/install.sh | sh"
if command -v herdr >/dev/null 2>&1; then
  v=$(herdr --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
  if [ "$(printf '%s\n' 0.9 "$v" | sort -V | head -1)" != 0.9 ]; then
    echo "  OLD       herdr $v      needs >= 0.9 for 'herdr agent prompt'; re-run herdr's install command"
  fi
fi
n=0
for p in "$HOME"/agy-profiles/*/; do
  [ -d "$p.gemini" ] && n=$((n + 1))
done
echo "  profiles  $n signed-in agy profile(s) in ~/agy-profiles (one per Gemini subscription)"

echo "Tools"
need optional gh "apt install gh, then gh auth login"
need optional uv "https://docs.astral.sh/uv/"
need optional graphify "uv tool install graphifyy   (double y)"
need optional browser-use "uv tool install --python 3.12 browser-use"
need optional mempalace-mcp "uv tool install mempalace   (only trust the GitHub repo and the PyPI package)"

[ "$bad" = 0 ] && echo "Ready." || echo "Fix the MISSING and PROBLEM lines under Required."
exit "$bad"
