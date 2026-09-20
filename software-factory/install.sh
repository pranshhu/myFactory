#!/usr/bin/env bash
# Apply the software factory to a project:  ./install.sh /path/to/project
#   new software      the folder does not exist yet: it is created and git-initialised
#   existing repo     the factory is added; files you already have are never overwritten
#   re-run            your edits are kept, third-party skills are re-fetched at the
#                     commits pinned in skills.tsv (this is also how you update them)
# Teammates need none of this: everything it installs is committed, so cloning the
# project gives them the same configuration. They run scripts/factory-doctor.sh.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
dir=${1:?usage: install.sh <project-dir>}
for t in git jq; do command -v "$t" >/dev/null || { echo "missing dependency: $t" >&2; exit 1; }; done
if [ ! -e "$dir" ]; then
  mkdir -p "$dir" && git -C "$dir" init -q -b main && echo "== created $dir"
fi
target=$(cd "$dir" && pwd)
manifest="$here/skills.tsv"
git -C "$target" rev-parse --git-dir >/dev/null 2>&1 || { echo "$target exists but is not a git repository (run git init in it first)" >&2; exit 1; }

echo "== template -> $target"
while IFS= read -r f; do
  if [ -e "$target/$f" ]; then
    cmp -s "$here/template/$f" "$target/$f" || echo "   kept yours, merge by hand: $f"
  else
    mkdir -p "$(dirname "$target/$f")" && cp -p "$here/template/$f" "$target/$f"
  fi
done < <(cd "$here/template" && find . -type f | sed 's|^\./||')

echo "== third-party skills (pinned in skills.tsv)"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
rows() { grep -v '^#' "$manifest"; }
while IFS=$'\t' read -r repo sha; do
  d="$tmp/${repo//\//_}"
  git init -q "$d"
  git -C "$d" remote add origin "https://github.com/$repo"
  # shellcheck disable=SC2046  # one sparse pattern per manifest path
  git -C "$d" sparse-checkout set --no-cone $(rows | awk -F'\t' -v r="$repo" '$1==r {print "/" $3}')
  git -C "$d" fetch -q --depth 1 --filter=blob:none origin "$sha"
  git -C "$d" checkout -q FETCH_HEAD
  echo "   $repo @ ${sha:0:7}"
done < <(rows | cut -f1,2 | sort -u)

while IFS=$'\t' read -r repo _ src dest; do
  case "$dest" in /* | *..*) echo "refusing suspicious dest: $dest" >&2; exit 1 ;; esac
  rm -rf "${target:?}/$dest"
  mkdir -p "$(dirname "$target/$dest")"
  cp -r "$tmp/${repo//\//_}/$src" "$target/$dest"
done < <(rows)
cp "$manifest" "$target/.agents/skills.sources.tsv" # provenance: what came from where, at which commit

echo "== adapting skills to this stack"
skills="$target/.agents/skills" cc="$target/.claude"
# superpowers skills are installed loose, not as the plugin: drop the plugin prefix from cross-references
{ grep -rlZ 'superpowers:' "$skills" || true; } | xargs -0r sed -i -E 's/superpowers:([a-z-]+)/\1/g'
# pstack writes generated skills to Cursor's folder
{ grep -rlZ '\.cursor/skills' "$skills" || true; } | xargs -0r sed -i 's|\.cursor/skills|.agents/skills|g'
# HumanLayer prompts assume their `thoughts` tool: flatten its layout, replace its sync step with git
{ grep -rlZ -e 'thoughts/shared/' -e 'humanlayer thoughts sync' "$cc/commands" "$cc/agents" || true; } |
  xargs -0r sed -i -e 's|thoughts/shared/|thoughts/|g' \
    -e 's|humanlayer thoughts sync|git add thoughts \&\& git commit -m "thoughts: update"|g'

# One skills folder for every agent: Claude Code reads .claude/skills, agy reads .agents/skills
if [ -e "$cc/skills" ] && [ ! -L "$cc/skills" ]; then
  echo "   .claude/skills already exists as a real folder; move its skills into .agents/skills and re-run"
else
  ln -sfn ../.agents/skills "$cc/skills"
fi
for ignore in .worktrees/ .artifacts/ .env; do
  grep -qxF "$ignore" "$target/.gitignore" 2>/dev/null || echo "$ignore" >>"$target/.gitignore"
done
chmod +x "$target/.agents/hooks/deny-dangerous.sh" "$target"/scripts/*.sh
echo "== command guard self-test"
"$target/.agents/hooks/deny-dangerous.sh" --test
echo "== this machine"
"$target/scripts/factory-doctor.sh" || true

cat <<EOF

Installed. Next, inside $target:
  1. Fill in CONTEXT.md and the Linear team key in docs/agents/issue-tracker.md.
  2. First issue, before any feature: "boots in Docker" (Dockerfile, compose.yaml, CHECK and PORT in the Makefile).
  3. Open Claude Code, approve the linear and mempalace MCP servers, run /setup-matt-pocock-skills
     (keep the existing Linear tracker doc).
  4. graphify .   and, once the app boots, /create-verification-skill
  5. Read the diff, then commit. Teammates clone and run scripts/factory-doctor.sh.
Walkthrough: $here/README.md    Every skill explained: docs/agents/skills.md
EOF
