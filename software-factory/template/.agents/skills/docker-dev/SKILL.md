---
name: docker-dev
description: Use whenever you build, run, test, migrate or debug project code, add a service or dependency, or set up a new project. All project code executes in Docker containers through make targets, never on the host.
---

# Docker dev

Agents run whatever the code they just wrote tells them to. A test that wipes a database, a script with a bad path, a dependency with an install hook: inside a container each of those costs one `make down`. On the host it costs a machine. So the host runs only git, docker and the agent CLIs. Everything else runs in a container.

It also makes every checkout identical: your machine, a teammate's, a builder's worktree and CI all run the same image.

## The interface

Every project has these targets. Use them; do not call `npm`, `pytest`, `go` or the like on the host.

| Command | Does |
|---|---|
| `make up` | Build and start the stack, return when healthchecks pass |
| `make check` | Lint with complexity budgets, typecheck, tests. The single definition of green, for tickets and for CI |
| `make url` | Print the app's URL for this checkout |
| `make shell` | A shell in the app container |
| `make logs` | Follow the stack's logs |
| `make down` | Stop and delete containers, network and volumes of this checkout |

One-off commands: `docker compose run --rm app <command>`. New dependency: add it to the manifest, then `make up` rebuilds the image.

## Rules for `compose.yaml` and the `Dockerfile`

1. **The service that holds the code is called `app`.** Databases, caches and queues are sibling services with pinned image tags and a `healthcheck`, so `make up` returning means ready.
2. **No fixed host ports.** Write `ports: ["3000"]`, never `"3000:3000"`. Several worktrees run at once and a fixed port makes the second one fail. `make url` finds the port Docker picked.
3. **One stack per worktree, for free.** Compose names a project after its folder, so `.worktrees/CRM-14` gets containers, a network and volumes of its own. Never set `container_name` or a fixed `name:`; both break this.
4. **Source is bind-mounted, dependencies are not.** `node_modules`, virtualenvs and build caches live in the image or a named volume.
5. **No escape hatches.** No `privileged`, no Docker socket mount, no `network_mode: host`, no `pid: host`, no mounts from outside the repository. Each one hands the container the host and defeats the point.
6. **No real credentials.** `.env` is gitignored and holds local values only; `.env.example` is committed. Production and staging secrets never enter a dev stack or an agent's environment.
7. **Data is disposable.** Seed with a script. For a production-shaped database (`migration` needs one), restore a scrubbed dump into the compose volume.
8. **CI runs `make check` too.** A gate that passes locally and fails in CI means something ran on the host. Find it.

## A new project's first issue

Size S, before any feature: "boots in Docker". A `Dockerfile`, a `compose.yaml` with `app` and its services, and `CHECK` and `PORT` set in the `Makefile`.

Done means, from a fresh clone with nothing installed but Docker:

```bash
make up && make check && curl -fsS "$(make url)" >/dev/null && make down
```

## Cleaning up

`make down` in a worktree before removing it, or its volumes are orphaned. `docker compose ls` shows every stack still running.
