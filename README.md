# myFactory

Factories: each folder holds the complete configuration, agent rules, skills and workflows to produce one kind of thing well, and an installer that applies it to a project.

| Factory | Produces | Status |
|---|---|---|
| [software-factory](software-factory/) | Production-grade software, SaaS first. Claude Code orchestrates, Antigravity builders write the code, Linear holds the state | first version |

A new factory is a new folder with the same shape: a README that explains the pipeline, a `template/` that gets copied into a project, and an `install.sh`.
