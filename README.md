## Hackathon Task

1. **Install Copilot CLI and configure skills** — set up the CLI, copy skills into `~/.agents/skills/`, and verify they load in VS Code.
2. **Watch the walkthrough video** — [Full flow walkthrough](https://www.youtube.com/watch?v=hX7yG1KVYhI) to understand the end-to-end workflow.
3. **Select a project idea and implement it using the new approach** — pick an idea, write a PRD, break it into issues, and let the AFK loop implement it.
4. **Write feedback about the experience** — answer the questions below [Feedback Questions](#feedback-questions) to capture your impressions.

## Requirements
 - Able to view audit log entries for VPG operations 📋
 - Each audit log entry must contain: VPG ID, operation name, a copy of the VPG changes, and a timestamp 🗂️
 - Audit log entries are immutable — once created, they cannot be edited or deleted 🔒
 - The audit log must be accessible via the ZIC REST API 🌐
 - Able to filter audit log entries by VPG ID 🔍
 - Able to filter audit log entries by date using the format dd/MM/yyyy 📆
 - Filters can be combined to narrow results by both VPG ID and date 🎯

## Toolkit Overview

A toolkit for autonomous coding with Copilot CLI and VS Code — includes reusable skills and an AFK loop for hands-off task execution.

## Installing Skills

Skills are prompt files that teach Copilot agents specialized workflows. Each skill lives in `skills/<skill-name>/SKILL.md`.

### Available skills

| Skill | Description |
|---|---|
| **write-a-prd** | Interview-driven PRD generation, saved as `issues/prd.md` |
| **prd-to-issues** | Break a PRD into vertical-slice issue files in `issues/` |
| **grill-me** | Stress-test a plan or design through relentless questioning |

### Install into VS Code (per-user)

Copy (or symlink) each skill folder into your global skills directory:

```bash
# Linux / macOS
cp -r skills/* ~/.agents/skills/

# Windows (PowerShell)
Copy-Item -Recurse skills\* "$env:USERPROFILE\.agents\skills\"
```

After copying, the skills are available in every workspace. Copilot will automatically pick them up based on the `description` field in the YAML frontmatter of each `SKILL.md`.

### Using skills

Once installed, invoke a skill in VS Code Copilot Chat by typing its name as a slash command:

- `/write-a-prd` — Interview-driven PRD generation
- `/prd-to-issues` — Break a PRD into vertical-slice issues
- `/grill-me` — Stress-test a plan or design

### Install into a single workspace

If you prefer workspace-scoped skills, copy the folders into `.github/skills/` at the root of your project:

```bash
mkdir -p .github/skills
cp -r skills/* .github/skills/
```

## Using `afk.sh`

`ralph/afk.sh` is an autonomous loop that lets Copilot CLI work through issues while you're away from keyboard.

> **Note:** Copy the `ralph/` folder into your target repository, or run the scripts from within the repository's directory context so they can access `issues/` and commit to the correct repo.

### Prerequisites

- [Copilot CLI](https://docs.github.com/en/copilot/github-copilot-in-the-cli) (`copilot` command available on PATH)
- `jq` installed (winget install jqlang.jq)
- A Git repository with issue files in `issues/` (markdown files describing tasks)
- The `ralph/prompt.md` file (included) which tells the agent how to pick and execute tasks

### How it works

1. Reads open issue files from `issues/` and recent git history.
2. Sends everything to Copilot CLI (Claude Sonnet) with tool access.
3. The agent picks one task, implements it (with TDD), runs tests/typecheck, and commits.
4. If the agent outputs `<promise>NO MORE TASKS</promise>`, the loop exits.
5. Otherwise it repeats for the number of iterations you specify.

### Usage

```bash
# Run 10 autonomous iterations
./ralph/afk.sh 10
```

The script will stream the agent's output in real time. Logs are written to `ralph/logs/`.

### Safety guardrails

The following destructive git commands are denied:

- `git push`
- `git reset`
- `git rebase`
- `git clean`

The agent commits locally but never pushes — you review and push when you're back.

### One-shot mode

`ralph/once.sh` runs a single iteration using `claude` CLI with `--permission-mode acceptEdits` instead of the loop. Useful for quick supervised runs.



### Feedback Questions

1. How did the autonomous workflow affect your overall productivity compared to your usual development process?
2. How confident did you feel in the quality of the code produced by the agent without manual intervention?
3. Were the generated PRD and issue breakdowns clear and actionable enough to guide implementation?
4. What was the biggest friction point or limitation you encountered during the hackathon?
5. Would you incorporate this approach (skills, AFK loop, PRD-driven development) into your day-to-day work? Why or why not?

## Resource links
- [Original skills repository](https://github.com/mattpocock/skills)
- [Original AFK bash script](https://github.com/mattpocock/ralph-workshop-repo-002/blob/main/plans/afk-claude.sh)
