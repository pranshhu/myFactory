# Machine setup

Once per person, per machine. It lives in the project so that a teammate who clones the repo has everything they need. Check where you stand at any time:

```bash
scripts/factory-doctor.sh
```

Skills, rules, hooks, subagents and MCP servers are **in the repo**, so cloning it gives you the same configuration as everyone else. This page covers only what cannot live in a repo: installed tools and logins.

## Tools

| Tool | Why | Install |
|---|---|---|
| Claude Code | Orchestrator | <https://claude.com/claude-code> |
| Docker + compose | All project code runs in containers | <https://docs.docker.com/engine/install/> |
| `jq`, `git`, `gh` | Guard hook, worktrees, PRs | `apt install jq git gh`, then `gh auth login` |
| `agy` | Builders | Antigravity CLI |
| `herdr` **≥ 0.9** | Panes the orchestrator can drive | `curl -fsSL https://herdr.dev/install.sh \| sh` |
| `graphify` | The code graph | `uv tool install graphifyy` (double y; other names on PyPI are not theirs) |
| `browser-use` | The only browser tool | `uv tool install --python 3.12 browser-use`, then `browser-use --doctor` |
| MemPalace | Agent memory | `uv tool install mempalace`. There are impostor sites spreading malware: trust only the GitHub repo and the PyPI package |

No agy or herdr? The factory still works: the orchestrator builds with the `builder` subagent instead. You lose the separate Gemini quota, nothing else.

herdr 0.7 has no `herdr agent prompt`, which `dispatch-builders` uses. `herdr --version`, and upgrade first.

## One agy profile per Gemini subscription

agy keeps its login under `$HOME`, so each account gets its own home:

```bash
mkdir -p ~/agy-profiles/acc1 ~/agy-profiles/acc2
for p in acc1 acc2; do
  ln -sf ~/.gitconfig ~/agy-profiles/$p/.gitconfig
  ln -sf ~/.ssh       ~/agy-profiles/$p/.ssh
done
HOME=~/agy-profiles/acc1 agy    # sign in with Google account 1, then /quit
HOME=~/agy-profiles/acc2 agy    # sign in with Google account 2, then /quit
```

A third subscription is `acc3` and one more builder pane. One subscription is just `acc1`. Anything installed per-user has to be installed once per profile, for example `HOME=~/agy-profiles/acc1 graphify install --platform antigravity`.

## Claude Code

Open the project and approve the two MCP servers from `.mcp.json` when asked: **linear** (sign in through the browser) and **mempalace**. If you already have Linear connected through a plugin or your user settings, decline the project's copy.

**Do not run the superpowers plugin in factory projects.** The factory installs the eight superpowers skills it wants as loose skills. The full plugin adds a session hook (`using-superpowers`, `brainstorming`) that forces its own intake on every message and fights `grill-with-docs`. If it is installed globally, disable it for the project with `/plugin`. A globally installed ponytail plugin is harmless; it says the same thing as `.agents/rules/ponytail.md`.

**Memory.** `mempalace init` once, then `mempalace mine <folder>` for anything worth remembering (old chats, client notes). A team that wants one shared memory runs `mempalace serve` on one machine and points `.mcp.json` at it.

## GitHub, once per repository

- Protect `main`: pull requests only, required checks `secrets`, `sast`, `check`, `strix`. An instruction file cannot stop a push; branch protection can. This is what makes the gate ladder real.
- Secrets: `STRIX_LLM`, `LLM_API_KEY`. For an organisation repo, also `GITLEAKS_LICENSE` (free).
- Install the Renovate app and Linear's GitHub integration.

## Check once by hand

Four things the installer cannot test. Each takes a minute.

1. **Skills reach the builders.** In the project: `HOME=~/agy-profiles/acc1 agy`, ask "which skills do you have?", expect `test-driven-development` in the list. Repeat for `acc2`.
2. **Account isolation.** Inside herdr:
   ```bash
   pane=$(herdr pane split --current --direction right --env HOME="$HOME/agy-profiles/acc1" --no-focus | jq -r .result.pane.pane_id)
   herdr agent start builder-a --kind agy --pane "$pane"
   ```
   Run `/stats` in that pane and confirm it shows Google account 1. If the environment does not reach agy, fall back to `herdr pane run "$pane" 'HOME=~/agy-profiles/acc1 agy'`.
3. **Detection.** `herdr agent prompt builder-a "Reply PONG" --wait --timeout 120000` should return `idle` or `done`, not time out. herdr reads agy's state off the screen, so an agy UI change can break this; `herdr agent read` keeps working when it does.
4. **Persistence.** `ctrl+b q` to detach mid-task, run `herdr` again, confirm the builder is still working. After a machine restart the layout comes back but the processes do not: re-dispatch unfinished issues.
