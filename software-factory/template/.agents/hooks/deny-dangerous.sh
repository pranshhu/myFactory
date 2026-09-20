#!/usr/bin/env bash
# Claude Code PreToolUse guard: hook JSON on stdin, exit 2 blocks the command.
# Guards against accidents, not adversaries: obfuscated commands slip past regex.
# Self-check after editing patterns: deny-dangerous.sh --test
dir=$(cd "$(dirname "$0")" && pwd)
patterns="$dir/dangerous-patterns.txt"

check() { # check <command>: prints the offending line, returns 0 when dangerous
  printf '%s\n' "$1" | grep -E -i -m1 -f <(grep -vE '^[[:space:]]*(#|$)' "$patterns")
}

if [ "${1:-}" = "--test" ]; then
  fail=0
  while IFS= read -r line; do
    want=${line%% *} cmd=${line#* }
    if check "$cmd" >/dev/null; then got=block; else got=allow; fi
    [ "$got" = "$want" ] || { echo "FAIL want=$want got=$got: $cmd"; fail=$((fail + 1)); }
  done <<'EOF'
block rm -rf /
block rm -rf /*
block rm -rf ~
block rm -fr ~/
block sudo rm -rf $HOME
block cd /tmp && rm -rf "/"
block rm -rf /home/someone
block rm -rf .git
block rm -r -f -- /etc
block git push --force
block git push -f origin feature
block git push origin +main
block git push origin --delete main
block git push origin :master
block gh repo delete acme/app --yes
block mkfs.ext4 /dev/sda1
block dd if=/dev/zero of=/dev/nvme0n1
block chmod -R 777 /
block :(){ :|:& };:
block terraform destroy
block tofu apply -auto-approve
block cat ~/agy-profiles/acc1/.gemini/antigravity-cli/antigravity-oauth-token
block cat ~/.ssh/id_ed25519
allow rm -rf node_modules
allow rm -rf ./dist build
allow rm -rf ~/agy-profiles/acc3
allow rm -rf /home/someone/project/tmp
allow rm -rf .worktrees/CRM-14
allow git push --force-with-lease origin CRM-14
allow git push -u origin CRM-14
allow git clean -fdx
allow git reset --hard HEAD~1
allow docker run --rm -v "$PWD:/src" image
allow terraform plan -out=tfplan
allow cat ~/.ssh/id_ed25519.pub
allow chmod +x scripts/spec_metadata.sh
EOF
  echo '{"tool_input":{"command":"rm -rf /"}}' | "$0" 2>/dev/null
  [ $? -eq 2 ] || { echo "FAIL hook path: JSON on stdin should exit 2"; fail=$((fail + 1)); }
  echo '{"tool_input":{"command":"ls"}}' | "$0" || { echo "FAIL hook path: ls should exit 0"; fail=$((fail + 1)); }
  echo "failed: $fail"
  exit $((fail > 0))
fi

# Fail open: a broken guard must not brick every Bash call.
command -v jq >/dev/null || exit 0
cmd=$(jq -r '.tool_input.command // empty' 2>/dev/null)
[ -n "$cmd" ] || exit 0
if hit=$(check "$cmd"); then
  echo "Blocked by .agents/hooks/dangerous-patterns.txt: $hit" >&2
  echo "This is irreversible. Do not work around it; ask the human to run it." >&2
  exit 2
fi
exit 0
