# SSD Workflow - Quick Start

## Installation

```bash
# Clone and install
git clone https://github.com/your-org/ssd-workflow.git
cd ssd-workflow
./install.sh
```

## First Task

```bash
# Start the SSD orchestrator
ssd --agent SSDOra

# Then type your task:
> "Create a user authentication API with JWT"
```

## What Happens

1. **Orchestrator** analyzes your task
2. **Context Engine** loads relevant patterns dynamically
3. **Model Router** selects optimal AI models
4. **Parallel Mesh** executes subtasks simultaneously
5. **Self-Healer** fixes errors autonomously
6. **Learning Agent** stores successful patterns
7. **Code delivered** with minimal human intervention

## Configuration

Edit `~/.config/ssd-workflow/config.yaml`:

```yaml
autonomy:
  auto_approve_threshold: 0.90  # Auto-approve if >90% confident
  require_approval_threshold: 0.50  # Require approval if <50%

budget:
  daily_limit: 10.00  # Max $10/day
```

## Demo

```bash
./bin/demo.sh
# Select a scenario, watch it work
```

## Metrics

Check learning and performance:
```bash
tail -f ~/.config/ssd-workflow/logs/ssd.log
cat ~/.config/ssd-workflow/context/learning/pattern-success.yaml
```

## Next Steps

- Read [docs/architecture.md](docs/architecture.md) for full design
- Customize context patterns in `context/patterns/`
- Adjust model routes in `config/routes/models.yaml`
- Set up team learning sync in config

---

**Ready to code autonomously?** `ssd --agent SSDOra`
