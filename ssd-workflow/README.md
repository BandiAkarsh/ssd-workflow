# SSD Development Workflow

> **Self-Determining System Development** - AI agents that think, learn, and adapt autonomously

[![License: MIT](https://img.shields.io/badge/License-MIT-3fb950?style=flat-square)](LICENSE)

## 🚀 What is SSD?

SSD is a next-generation AI development workflow where agents:
- **Self-direct** their own task decomposition and execution strategy
- **Self-correct** when errors occur, trying alternative approaches autonomously
- **Self-learn** from human feedback, storing patterns for future use
- **Dynamically adapt** context based on real-time needs, not static files
- **Execute in parallel** with intelligent mesh coordination

Built on OpenCode but reimagined for 2026's AI capabilities.

## 📊 Comparison: OAC vs SSD

| Feature | OpenAgentsControl | SSD Workflow |
|---------|-------------------|--------------|
| **Context** | Static markdown files | Dynamic, weighted, learning |
| **Workflow** | Sequential + approval gates | Parallel mesh + smart gates |
| **Model Routing** | Manual selection | Intelligent task-based routing |
| **Error Handling** | Human catches errors | Autonomous self-healing |
| **Learning** | Manual context updates | Auto-learn from feedback |
| **Memory** | Session-only | Persistent cross-session |
| **Autonomy** | Human-guided | Self-determining with oversight |
| **Token Efficiency** | MVI principle | Adaptive context loading |

## 🏗️ Architecture

```
ssd-workflow/
├── agent/
│   ├── orchestrator/      # Main SSD orchestrator (replaces OpenCoder)
│   ├── subagents/         # Specialized autonomous agents
│   └── skills/            # Dynamic capabilities
├── context/
│   ├── patterns/          # Learned patterns (auto-updated)
│   ├── weights/           # Context relevance weights
│   ├── memory/            # Session-to-session memory
│   └── learning/          # Human feedback database
├── config/
│   ├── routes/            # Model routing rules
│   ├── heuristics/        # Task decomposition AI
│   └── policies/          # Self-healing policies
└── state/
    ├── sessions/          # Session persistence
    └── evolution/         # Project pattern evolution
```

## 🎯 Core Innovations

### 1. Neural Context Engine
- Real-time context updating based on success patterns
- Weighted relevance that learns from usage
- Auto-context generation from codebase analysis
- Pattern extraction from human corrections

### 2. Intelligent Model Router
- Task-based routing to optimal models
- Cost-performance optimization
- Automatic fallback on failure
- Multi-model collaboration on complex tasks

### 3. Parallel Agent Mesh
- Dependency-aware parallel execution
- Cross-agent communication mid-execution
- Intelligent result merging
- Conflict resolution strategies

### 4. Self-Healing System
- Autonomous error detection and correction
- Multiple retry strategies
- Confidence scoring
- Smart escalation to human

### 5. Persistent Learning
- Session memory across restarts
- Pattern evolution tracking
- Feedback loop integration
- Team knowledge sharing

## 🚦 Quick Start

### Installation

```bash
# Clone and setup
git clone https://github.com/your-org/ssd-workflow.git
cd ssd-workflow
./install.sh

# Or use OpenCode directly
opencode --agent SSDOra
```

### First Use

```bash
# Start the SSD orchestrator
opencode --agent SSDOra
> "Build a user authentication system with JWT"

# What happens:
# 1. Orchestrator analyzes task complexity
# 2. Routes to optimal models (Claude for architecture, GPT for implementation)
# 3. Decomposes into parallel subtasks
# 4. Executes simultaneously with self-validation
# 5. Merges results, self-corrects if needed
# 6. Learns from your feedback
# 7. Ships production-ready code
```

## 📖 How It Works

### Traditional (OAC)
```
User request → Agent proposes → Human approves → Agent executes → Human validates
```
**Human role:** Constant oversight, manual corrections

### SSD Workflow
```
User request → Orchestrator routes → Parallel agents execute → 
Self-validate → Self-correct if needed → Present results → 
Learn from feedback → Update patterns
```
**Human role:** Set direction, review final output, provide feedback

## 🔧 Configuration

### Model Routing Rules
```yaml
# config/routes/default.yaml
routes:
  - task_type: "architecture"
    models: ["claude-opus-4", "gpt-5"]
    strategy: "consensus"
  
  - task_type: "implementation"
    models: ["claude-sonnet-4.5", "gpt-4o-mini"]
    strategy: "fastest"
  
  - task_type: "testing"
    models: ["claude-sonnet-4.5"]
    strategy: "single"
```

### Self-Healing Policies
```yaml
# config/policies/self-heal.yaml
retry_strategies:
  - error_type: "type_error"
    strategy: "regenerate_with_type_hints"
    max_attempts: 3
  
  - error_type: "test_failure"
    strategy: "fix_tests_first"
    max_attempts: 2
```

## 📈 Learning System

SSD learns from every interaction:

1. **Success Patterns** - Store what worked for similar tasks
2. **Human Corrections** - Learn from manual fixes
3. **Context Weights** - Adjust relevance based on usage
4. **Model Performance** - Track which models excel at which tasks

### Example Learning Cycle

```
Task: "Create API endpoint"
├─ Agent generates code (pattern: zod-validation)
├─ Human approves ✓
├─ Pattern stored with +1 weight
└─ Future tasks: auto-apply this pattern

Task: "Create API endpoint"
├─ Agent generates code (pattern: zod-validation)
├─ Human modifies: "Use yup instead"
├─ Correction learned: zod → yup mapping
└─ Future tasks: ask "validation library?" if ambiguous
```

## 🛠️ Advanced Features

### Dynamic Context Loading
```javascript
// Before: Load all context files
loadContext(['api-patterns', 'component-standards', 'testing']);

// After: Load only what's needed, weighted by past success
const needed = contextEngine.analyze(task);
const weighted = contextEngine.weight(needed);
// 80% fewer tokens, same or better quality
```

### Parallel Mesh Execution
```javascript
// Task: "Build auth system"
// Automatically decomposed:
// ├─ API endpoints (parallel)
// ├─ Database schema (parallel)
// ├─ Frontend components (parallel)
// └─ Tests (sequential, depends on above)

// All independent tasks execute simultaneously
```

### Smart Approval Gates
```javascript
// Not all changes need approval:
// - Trivial formatting: auto-approve ✓
// - Pattern-matched code: auto-approve ✓
// - New patterns: require approval ⚠️
// - High-risk changes: require approval ⚠️

// Confidence scoring determines gate level
```

## 📊 Metrics & Monitoring

SSD tracks:
- **Autonomy Score** - % of tasks completed without human intervention
- **Learning Velocity** - Patterns learned per week
- **Token Efficiency** - Context tokens vs output quality
- **Self-Heal Rate** - Errors fixed autonomously
- **Parallel Utilization** - % of tasks executed in parallel

## 🤝 Contributing

This is experimental 2026 tech. Contributions welcome!

1. Fork the repository
2. Create feature branch
3. Implement with tests
4. Submit PR with metrics

## 📄 License

MIT - See LICENSE for details.

## 🙏 Acknowledgments

Built on the shoulders of:
- [OpenCode](https://opencode.ai) - The foundation
- [OpenAgentsControl](https://github.com/darrenhinde/OpenAgentsControl) - Inspiration
- The AI engineering community pushing boundaries

---

**Ready to build the future?** Let's create agents that think for themselves.
