# SSD Workflow Architecture

## Executive Summary

SSD (Self-Determining System Development) reimagines AI-assisted development from **human-guided** to **agent-autonomous** with human oversight. Instead of agents waiting for approval at every step, SSD agents:

1. **Think** - Analyze tasks and decompose autonomously
2. **Plan** - Create execution strategies with confidence scores
3. **Execute** - Run in parallel with self-validation
4. **Correct** - Detect and fix errors without human intervention
5. **Learn** - Store successful patterns for future use
6. **Adapt** - Dynamically adjust context and strategies

**Human Role Changes:** From "micro-manager" to "strategic director"

---

## Core Components

### 1. Orchestrator Brain (`agent/orchestrator/brain.md`)

The central intelligence that replaces sequential workflows.

#### Responsibilities:
- **Task Analysis** - Understand complexity, dependencies, required expertise
- **Model Routing** - Select optimal AI models for each subtask
- **Decomposition Strategy** - Break into parallelizable units
- **Confidence Assessment** - Evaluate certainty before execution
- **Result Synthesis** - Merge outputs from multiple agents
- **Escalation Decision** - Know when to involve human

#### Decision Flow:
```
Input: "Build auth system with OAuth"

1. Complexity Analysis
   ├─ Simple (1-2 files) → Direct execution
   ├─ Medium (3-10 files) → Decompose + parallel
   └─ Complex (10+ files) → Full mesh orchestration

2. Expertise Mapping
   ├─ Auth → security-specialist
   ├─ Database → backend-specialist
   ├─ UI → frontend-specialist
   └─ Tests → test-engineer

3. Model Assignment
   ├─ Security: Claude Opus (high reasoning)
   ├─ Backend: GPT-4o (fast, reliable)
   ├─ Frontend: Claude Sonnet (creative)
   └─ Tests: GPT-4o-mini (fast, cheap)

4. Parallel Execution Plan
   └─ Independent tasks → simultaneous
      Dependent tasks → sequential with handoffs

5. Confidence Thresholds
   ├─ >90%: Auto-execute, minimal review
   ├─ 70-90%: Execute, flag for post-review
   └─ <70%: Request human approval pre-execution
```

#### Autonomy Levels:
- **Level 1 (Full Auto)** - Trivial tasks, high confidence
- **Level 2 (Execute & Report)** - Standard tasks, self-validate
- **Level 3 (Plan & Approve)** - Complex tasks, need approval
- **Level 4 (Collaborative)** - Novel tasks, human-in-loop

---

### 2. Neural Context Engine (`agent/subagents/context-engine/`)

Replaces static context files with dynamic, learning-based context.

#### Innovations:

**A. Context Weighting**
```yaml
# context/weights/patterns.yaml
patterns:
  zod-validation:
    weight: 0.95  # Used in 47 recent tasks, 100% approval
    last_used: 2026-04-17
    success_rate: 0.98
  
  drizzle-orm:
    weight: 0.87  # Used in 32 tasks, 1 correction needed
    last_used: 2026-04-16
    success_rate: 0.94
```

**B. Real-time Context Generation**
```javascript
// Instead of loading all files:
const context = await contextEngine.analyze(task);
// Returns ONLY what's needed, weighted by:
// - Past success for similar tasks
// - Recent usage frequency
// - Human correction patterns
// - Team standards relevance
```

**C. Pattern Learning from Corrections**
```
Human correction: "Use yup instead of zod for validation"
↓
ContextEngine learns:
  - zod → yup mapping for validation tasks
  - Update pattern weights
  - Store in context/learning/corrections.yaml
↓
Future tasks: "Which validation library?" → Check learned preference
```

**D. Auto-Context Extraction**
```bash
# Scan codebase to generate context
./scripts/context/extract-patterns.sh
# Outputs:
# - API patterns (from existing endpoints)
# - Component patterns (from existing UI)
# - Testing patterns (from existing tests)
# - Naming conventions (from file structure)
```

---

### 3. Self-Healing System (`agent/subagents/self-healer/`)

Autonomous error detection and correction.

#### Error Detection:
- **Static Analysis** - Type checking, linting before execution
- **Runtime Prediction** - Anticipate failures from code patterns
- **Test Simulation** - Run mental tests before actual execution
- **Dependency Validation** - Check imports, exports, types

#### Self-Correction Strategies:
```yaml
# config/policies/self-heal.yaml
strategies:
  type_error:
    - attempt: 1
      action: "add_type_annotations"
    - attempt: 2
      action: "use_any_as_fallback"
    - attempt: 3
      action: "request_human_help"
  
  test_failure:
    - attempt: 1
      action: "fix_tests_to_match_implementation"
    - attempt: 2
      action: "adjust_implementation_to_pass_tests"
    - attempt: 3
      action: "rewrite_both_tests_and_impl"
  
  import_error:
    - attempt: 1
      action: "check_typo_and_fix"
    - attempt: 2
      action: "search_for_similar_module"
    - attempt: 3
      action: "ask_human_for_correct_import"
```

#### Confidence Scoring:
```javascript
const confidence = await selfHealer.assess(proposedCode);
// Returns: { score: 0.87, risks: [...], mitigation: [...] }

if (confidence.score < 0.7) {
  // Escalate to human before execution
  await requestApproval(proposedCode, confidence);
} else if (confidence.score < 0.9) {
  // Execute but flag for post-review
  await executeWithFlag(proposedCode, 'review-needed');
} else {
  // Auto-execute
  await execute(proposedCode);
}
```

---

### 4. Parallel Agent Mesh (`agent/subagents/parallel-executor/`)

Intelligent parallel execution with dependency resolution.

#### Dependency Graph:
```javascript
// Task: "Build e-commerce checkout"
const deps = await analyzer.buildDependencyGraph(task);
/*
{
  "api-endpoints": { deps: [], parallel: true },
  "database-schema": { deps: [], parallel: true },
  "payment-integration": { deps: ["api-endpoints"], parallel: false },
  "frontend-components": { deps: ["api-endpoints"], parallel: true },
  "tests": { deps: ["api-endpoints", "database-schema", "payment-integration", "frontend-components"], parallel: false }
}
*/
```

#### Execution Strategy:
```yaml
Batch 1 (parallel):
  - api-endpoints
  - database-schema
  - frontend-components  # All independent, run simultaneously

Batch 2 (sequential):
  - payment-integration  # Depends on Batch 1

Batch 3 (sequential):
  - tests  # Depends on everything
```

#### Cross-Agent Communication:
```javascript
// Agents share findings mid-execution
agent1.communicate({
  to: "payment-integration",
  message: "API uses /api/checkout endpoint, expects {amount, currency}",
  type: "discovery"
});

// Other agents update their context
agent2.receive(communication);
agent2.updateLocalContext(communication.content);
```

---

### 5. Intelligent Model Router (`agent/orchestrator/router.md`)

Task-based model selection with fallback orchestration.

#### Routing Rules:
```yaml
# config/routes/models.yaml
routing:
  architecture_design:
    primary: "claude-opus-4"
    fallback: "gpt-5"
    strategy: "consensus"  # Use both, merge results
  
  implementation:
    primary: "claude-sonnet-4.5"
    fallback: "gpt-4o"
    strategy: "fastest"  # Use whichever responds first
  
  testing:
    primary: "gpt-4o-mini"
    fallback: "claude-haiku"
    strategy: "cost_optimized"  # Cheapest that works
  
  creative_ui:
    primary: "claude-opus-4"
    fallback: "gpt-5"
    strategy: "best_of_three"  # Generate 3, pick best
```

#### Cost Optimization:
```javascript
// Estimate task cost before execution
const costEstimate = await router.estimateCost(task);
if (costEstimate > budget) {
  // Use cheaper models for non-critical parts
  await router.adjustForBudget(task, budget);
}
```

---

## Workflow: Before vs After

### Before (OAC)
```
1. User: "Create auth system"
2. ContextScout: Loads 20 context files (5000 tokens)
3. OpenCoder: Proposes plan (waits for approval)
4. Human: Approves ✓
5. OpenCoder: Implements file 1
6. OpenCoder: Implements file 2
7. OpenCoder: Implements file 3
8. TestEngineer: Adds tests
9. CodeReviewer: Reviews
10. Human: Validates, finds issues
11. Human: Manually fixes
12. Total time: 45 minutes, 20 human interactions
```

### After (SSD)
```
1. User: "Create auth system"
2. Orchestrator:
   - Analyzes: "Medium complexity, 5 files, needs security expertise"
   - Routes: Claude Opus (architecture) + GPT-4o (implementation)
   - Decomposes: 3 parallel tasks (API, DB, UI)
   - Confidence: 0.92 (high)
3. Parallel Execution (simultaneous):
   - Agent1 (API): Creates endpoints with self-validation
   - Agent2 (DB): Creates schema with type checking
   - Agent3 (UI): Creates components with design patterns
4. Self-Healing:
   - Agent2 detects foreign key issue
   - Auto-fixes with corrected migration
5. Synthesis:
   - Orchestrator merges results
   - Runs integration check
   - Confidence: 0.95
6. Auto-Execute (no approval needed, high confidence)
7. Learning:
   - Store successful auth pattern
   - Update context weights
   - Note: "Used zod-validation, drizzle-orm, shadcn-components"
8. Total time: 12 minutes, 2 human interactions (review only)
```

---

## File Structure

```
ssd-workflow/
├── agent/
│   ├── orchestrator/
│   │   ├── brain.md              # Core decision logic
│   │   ├── router.md             # Model routing
│   │   ├── mesh.md               # Parallel coordination
│   │   └── synthesizer.md        # Result merging
│   ├── subagents/
│   │   ├── context-engine/
│   │   │   ├── analyzer.md       # Context analysis
│   │   │   ├── weighter.md       # Pattern weighting
│   │   │   ├── learner.md        # Pattern learning
│   │   │   └── generator.md      # Auto-context generation
│   │   ├── self-healer/
│   │   │   ├── detector.md       # Error detection
│   │   │   ├── strategist.md     # Correction strategies
│   │   │   └── executor.md       # Retry logic
│   │   ├── learning-agent/
│   │   │   ├── feedback.md       # Human feedback processing
│   │   │   ├── pattern-store.md  # Pattern database
│   │   │   └── evolution.md      # Track changes over time
│   │   ├── parallel-executor/
│   │   │   ├── dependency.md     # Graph builder
│   │   │   ├── scheduler.md      # Batch scheduling
│   │   │   ├── communicator.md   # Cross-agent messaging
│   │   │   └── merger.md         # Result synthesis
│   │   └── model-orchestrator/
│   │       ├── selector.md       # Model selection
│   │       ├── fallback.md       # Failover handling
│   │       └── cost-tracker.md   # Budget management
│   └── skills/
│       ├── dynamic-context.md    # Real-time context
│       ├── self-correction.md    # Autonomous fixes
│       ├── pattern-learning.md   # Learn from feedback
│       ├── mesh-execution.md     # Parallel coordination
│       └── confidence-scoring.md # Quality assessment
├── context/
│   ├── patterns/
│   │   ├── api-endpoints.yaml   # Learned API patterns
│   │   ├── components.yaml      # Learned UI patterns
│   │   ├── testing.yaml         # Learned test patterns
│   │   └── security.yaml        # Learned security patterns
│   ├── weights/
│   │   ├── patterns.yaml        # Pattern success weights
│   │   ├── models.yaml          # Model performance weights
│   │   └── tasks.yaml           # Task-type weights
│   ├── memory/
│   │   ├── sessions/            # Per-session memory
│   │   ├── cross-session.yaml   # Persistent learnings
│   │   └── decisions.log        # Decision history
│   └── learning/
│       ├── corrections.yaml     # Human corrections
│       ├── feedback.yaml        # Explicit feedback
│       └── preferences.yaml     # Team preferences
├── config/
│   ├── routes/
│   │   ├── models.yaml          # Model routing rules
│   │   ├── tasks.yaml           # Task classification
│   │   └── fallback.yaml        # Failover strategies
│   ├── heuristics/
│   │   ├── decomposition.yaml   # How to break down tasks
│   │   ├── confidence.yaml      # Confidence calculation
│   │   └── parallel-detection.yaml # Parallelism detection
│   └── policies/
│       ├── self-heal.yaml       # Error correction policies
│       ├── approval-thresholds.yaml # When to ask human
│       └── safety.yaml          # Safety constraints
├── state/
│   ├── sessions/
│   │   └── {session-id}.yaml    # Current session state
│   └── evolution/
│       ├── patterns-{date}.yaml # Pattern evolution snapshots
│       └── metrics.yaml         # Long-term metrics
└── docs/
    ├── architecture.md          # This document
    ├── configuration.md         # Config guide
    ├── migration.md             # OAC → SSD migration
    └── examples/                # Usage examples
```

---

## Key Design Decisions

### 1. Why Dynamic Context Over Static Files?

**Static files (OAC):**
- Pros: Simple, versionable, explicit
- Cons: Manual updates, no learning, token-inefficient

**Dynamic context (SSD):**
- Pros: Auto-updates, learns from usage, token-efficient, adaptive
- Cons: Requires storage, needs monitoring

**Decision:** SSD prioritizes long-term efficiency over initial simplicity.

### 2. Why Parallel Mesh Over Sequential?

**Sequential (OAC):**
- Pros: Predictable, easy to debug
- Cons: Slow, no agent communication, siloed

**Parallel Mesh (SSD):**
- Pros: 3-5x faster, agents share knowledge, better results
- Cons: More complex, needs dependency resolution

**Decision:** SSD assumes modern hardware can handle parallelism.

### 3. Why Self-Healing Over Human-Only Validation?

**Human-only (OAC):**
- Pros: Human judgment, catches edge cases
- Cons: Time-consuming, repetitive, human as bottleneck

**Self-healing (SSD):**
- Pros: Fast, autonomous, learns from mistakes
- Cons: May miss subtle issues, needs good strategies

**Decision:** SSD uses confidence scoring to escalate uncertain cases.

### 4. Why Model Routing Over Single Model?

**Single model (OAC):**
- Pros: Simple, consistent
- Cons: Suboptimal for different task types, expensive if using best model always

**Model routing (SSD):**
- Pros: Cost-optimized, quality-optimized, flexible
- Cons: More complex, needs good routing rules

**Decision:** SSD treats model selection as optimization problem.

---

## Implementation Phases

### Phase 1: Core Orchestrator (Week 1-2)
- [ ] Basic brain with task analysis
- [ ] Simple model routing (2-3 models)
- [ ] Sequential execution (no parallel yet)
- [ ] Basic confidence scoring

### Phase 2: Parallel Execution (Week 3-4)
- [ ] Dependency graph builder
- [ ] Parallel executor with 2-3 agents
- [ ] Cross-agent communication
- [ ] Result merger

### Phase 3: Self-Healing (Week 5-6)
- [ ] Error detection system
- [ ] Retry strategies (3-5 patterns)
- [ ] Confidence assessment
- [ ] Smart approval gates

### Phase 4: Neural Context (Week 7-8)
- [ ] Context weighting system
- [ ] Pattern learning from corrections
- [ ] Auto-context generation
- [ ] Memory persistence

### Phase 5: Polish & Integration (Week 9-10)
- [ ] Full integration testing
- [ ] Performance optimization
- [ ] Documentation
- [ ] Migration tools from OAC

---

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Autonomy Score** | >80% tasks auto-executed | % tasks with confidence >90% |
| **Token Efficiency** | 50% reduction vs OAC | Avg context tokens per task |
| **Parallel Utilization** | >60% tasks parallelizable | % tasks in parallel batches |
| **Self-Heal Rate** | >40% errors auto-fixed | % errors corrected without human |
| **Learning Velocity** | >5 patterns/week | New patterns stored per week |
| **Time to Task** | <15 min for medium tasks | Avg time from request to code |
| **Human Interventions** | <2 per feature | Avg human touches per feature |

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Over-autonomy → bad code | High | Confidence thresholds, post-review flags |
| Context corruption | Medium | Versioned context, rollback capability |
| Model routing errors | Medium | A/B testing, fallback strategies |
| Parallel conflicts | Medium | Intelligent merging, conflict resolution |
| Learning from bad examples | High | Human validation of learned patterns |
| Cost overruns | Medium | Budget tracking, cost-aware routing |

---

## Migration from OAC

### Step 1: Install SSD alongside OAC
```bash
# Both can coexist
~/.config/opencode/  # OAC
~/.config/ssd-workflow/  # SSD
```

### Step 2: Export OAC Context
```bash
opencode --agent OpenCoder
> /export-context --format ssd
# Converts OAC context to SSD pattern format
```

### Step 3: Start with Simple Tasks
```bash
opencode --agent SSDOra
> "Add login form component"  # Simple, build confidence
```

### Step 4: Gradual Migration
- Week 1-2: SSD for new features, OAC for complex
- Week 3-4: SSD for 50% of work
- Week 5-6: SSD for 80% of work
- Week 7+: Full SSD, OAC as fallback

---

## Future Vision

SSD represents the **autonomous developer assistant** of 2026:

- **Week 1-6:** This implementation (core autonomy)
- **Month 6-12:** Team learning, shared pattern libraries
- **Year 2:** Predictive task decomposition, proactive suggestions
- **Year 3:** Full project autonomy with human strategic direction

**The goal:** Developers spend 80% time on design & review, 20% on implementation oversight.

---

*Built for the era of "vibe coding" → "agentic engineering"*
