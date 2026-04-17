---
description: "Dynamic context analysis and weighted pattern loading"
version: "0.1.0"
---

# Neural Context Engine - Analyzer

Intelligent context system that learns from usage, weights patterns by success, and generates context dynamically.

---

## Problem with Static Context

**OAC Approach:**
```
Load ALL context files:
- api-patterns.md (200 lines)
- component-standards.md (150 lines)
- testing-guidelines.md (180 lines)
- security-requirements.md (120 lines)
- ... 20 more files
Total: ~5000 tokens per task
```

**Problems:**
- Most context unused per task
- Token waste → higher costs, slower responses
- No learning → same files always loaded
- Manual updates → stale patterns

---

## SSD Solution: Dynamic Weighted Context

### Real-Time Context Analysis
```javascript
async function analyzeTaskForContext(task) {
  // 1. Classify task type
  const taskType = await classifyTask(task.description);
  // "implementation", "testing", "architecture", etc.
  
  // 2. Find similar past tasks
  const similarTasks = await findSimilarTasks(task, limit: 10);
  // Returns: [{ task: "...", patterns: [...], success: true }, ...]
  
  // 3. Extract patterns from successful similar tasks
  const successfulPatterns = similarTasks
    .filter(t => t.success)
    .flatMap(t => t.patterns);
  
  // 4. Weight patterns by frequency
  const patternWeights = calculateWeights(successfulPatterns);
  // {
  //   "zod-validation": 0.95,  // Used in 47 tasks, 100% success
  //   "drizzle-orm": 0.87,     // Used in 32 tasks, 94% success
  //   "shadcn-components": 0.92 // Used in 28 tasks, 98% success
  // }
  
  // 5. Load only top-weighted patterns
  const topPatterns = Object.entries(patternWeights)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 10)  // Top 10 patterns
    .map(p => p[0]);
  
  const context = await loadPatterns(topPatterns);
  
  return {
    patterns: context,
    weights: patternWeights,
    estimatedTokens: context.tokenCount,
    confidence: calculateConfidence(similarTasks)
  };
}
```

---

## Pattern Weighting System

### Weight Calculation Factors
```javascript
function calculatePatternWeight(pattern) {
  let weight = 0;
  
  // 1. Usage frequency (normalized)
  weight += log(usageCount + 1) * 0.3;  // log scale, diminishing returns
  
  // 2. Success rate
  weight += successRate * 0.4;  // 0.0-1.0
  
  // 3. Recency (exponential decay)
  const daysSinceLastUsed = (now - lastUsed) / (1000 * 60 * 60 * 24);
  weight += Math.exp(-daysSinceLastUsed / 30) * 0.2;  // 30-day half-life
  
  // 4. Human validation bonus
  if (humanApproved) weight += 0.1;
  
  // 5. Team standard bonus
  if (isTeamStandard) weight += 0.1;
  
  return clamp(weight, 0, 1);
}
```

### Example Weights
```yaml
# context/weights/patterns.yaml (auto-generated)
patterns:
  zod-validation:
    weight: 0.95
    usage_count: 47
    success_rate: 1.00
    last_used: 2026-04-17
    human_approved: true
    team_standard: true
  
  drizzle-orm:
    weight: 0.87
    usage_count: 32
    success_rate: 0.94
    last_used: 2026-04-16
    human_approved: true
    team_standard: true
  
  shadcn-components:
    weight: 0.92
    usage_count: 28
    success_rate: 0.98
    last_used: 2026-04-15
    human_approved: true
    team_standard: true
  
  custom-hook-auth:
    weight: 0.45
    usage_count: 3
    success_rate: 0.67
    last_used: 2026-04-10
    human_approved: false  # Human modified after generation
    team_standard: false
```

---

## Auto-Context Generation

### Extract Patterns from Codebase
```bash
# Run periodically or on new project
./scripts/context/extract-patterns.sh

# What it does:
# 1. Scan existing code for patterns
# 2. Identify:
#    - API patterns (routing, validation, response format)
#    - Component patterns (structure, props, hooks)
#    - Testing patterns (framework, structure, mocks)
#    - Database patterns (ORM, queries, migrations)
#    - Naming conventions (files, variables, functions)
# 3. Generate context files in context/patterns/
# 4. Assign initial weights (based on usage frequency)
```

### Example Extraction
```javascript
// From existing codebase:
src/
├── app/
│   ├── api/
│   │   ├── users/
│   │   │   └── route.ts  // POST /api/users
│   │   └── auth/
│   │       └── route.ts  // POST /api/auth/login
│   └── dashboard/
│       └── page.tsx

// Extracted pattern:
context/patterns/api-endpoints.yaml:
pattern: "nextjs-app-router-api"
examples:
  - file: "src/app/api/users/route.ts"
    method: "POST"
    validation: "zod"
    response: "json with status code"
    auth: "optional"
weight: 0.8  # 2 endpoints found
```

---

## Context Learning Loop

### 1. During Task Execution
```javascript
// Agent uses certain patterns
const usedPatterns = await agent.execute(task, context);
// Log: ["zod-validation", "drizzle-orm", "shadcn-button"]

// After success:
await contextEngine.recordUsage({
  task: task.description,
  taskType: task.type,
  patterns: usedPatterns,
  success: true,
  confidence: 0.92,
  humanApproved: true
});

// Update weights:
for (const pattern of usedPatterns) {
  const current = getWeight(pattern);
  const newWeight = current * 0.95 + 0.05;  // Small boost
  setWeight(pattern, newWeight);
}
```

### 2. Human Feedback Integration
```javascript
// Human modifies generated code
// Detect changes:
const diff = compare(originalCode, humanModified);
const changedPatterns = detectPatternChanges(diff);

// Learn from corrections:
for (const pattern of changedPatterns) {
  if (pattern.wasGenerated && pattern.wasModified) {
    // Human didn't like this pattern → decrease weight
    const current = getWeight(pattern.id);
    const newWeight = current * 0.9;  // Penalize
    setWeight(pattern.id, newWeight);
    
    // Store correction
    await learningAgent.storeCorrection({
      pattern: pattern.id,
      original: pattern.generated,
      corrected: pattern.humanModified,
      reason: await inferReason(diff),
      task: task.description
    });
  }
}
```

### 3. Periodic Re-weighting
```bash
# Run weekly: ./scripts/context/reweight.sh
# Recalculates all pattern weights based on:
# - 30-day usage history
# - Success rates
# - Human approval rates
# - Team standard adoption
```

---

## Context Storage Format

### Pattern Files
```yaml
# context/patterns/zod-validation.yaml
id: zod-validation
type: validation-library
language: typescript
framework: nextjs, express
description: "Zod schema validation for API inputs"
tags: ["validation", "schema", "typescript"]

example: |
  import { z } from 'zod';
  
  const UserSchema = z.object({
    email: z.string().email(),
    name: z.string().min(2),
    age: z.number().int().positive()
  });
  
  export async function POST(request: Request) {
    const body = await request.json();
    const validated = UserSchema.parse(body);  // Throws if invalid
    // ...
  }

usage_guidelines:
  - "Always validate API inputs with Zod"
  - "Define schemas separately for reusability"
  - "Use .parse() for throwing, .safeParse() for non-throwing"

weight: 0.95
last_used: 2026-04-17T10:30:00Z
success_count: 47
failure_count: 0
human_approved: true
team_standard: true
```

### Weight Database
```yaml
# context/weights/patterns.yaml
version: 1.2
last_updated: 2026-04-17T12:00:00Z
patterns:
  zod-validation:
    weight: 0.95
    usage_30d: 47
    success_rate: 1.00
    trend: "+0.02"  # Increased from last reweight
  
  drizzle-orm:
    weight: 0.87
    usage_30d: 32
    success_rate: 0.94
    trend: "-0.01"  # Slight decrease
  
  shadcn-components:
    weight: 0.92
    usage_30d: 28
    success_rate: 0.98
    trend: "stable"
```

---

## Context Discovery Process

### Step 1: Task Analysis
```javascript
const analysis = await analyzeTask(task);
// Returns: { type: "implementation", domain: "backend", complexity: "medium" }
```

### Step 2: Pattern Matching
```javascript
const candidates = await findPatterns(analysis);
// Search patterns where:
// - type matches OR domain matches
// - weight > 0.5
// - used in last 30 days (or high weight)
// Returns: 20-30 candidate patterns
```

### Step 3: Weighted Selection
```javascript
const selected = candidates
  .sort((a, b) => b.weight - a.weight)
  .slice(0, 10);  // Top 10

// But also include:
// - 1-2 random lower-weight patterns (exploration)
// - 1 pattern from similar but different domain (cross-pollination)
```

### Step 4: Context Assembly
```javascript
const context = {
  system: loadSystemContext(),  // Always include
  patterns: await loadPatterns(selected),
  memory: await loadRelevantMemory(task),
  constraints: await loadConstraints(task)
};

// Token count: ~2000-3000 (vs 5000+ in OAC)
```

---

## Memory System

### Short-Term (Session)
```javascript
// Remember what happened in current session
sessionMemory = {
  decisions: [...],  // Key decisions made
  patternsTried: [...],  // Patterns attempted
  errors: [...],  // Errors encountered
  corrections: [...]  // Human corrections
};
```

### Long-Term (Cross-Session)
```javascript
// Persist learnings across sessions
crossSessionMemory = {
  successfulPatterns: {
    "authentication": {
      pattern: "jwt-with-refresh-tokens",
      usedIn: 12 tasks,
      lastUsed: "2026-04-17"
    }
  },
  commonMistakes: {
    "type-errors": {
      pattern: "forgot-to-return-response",
      fix: "add return statement",
      frequency: 0.15
    }
  },
  teamPreferences: {
    "validation": "zod",
    "orm": "drizzle",
    "ui": "shadcn"
  }
};
```

---

## Token Efficiency Gains

### OAC (Static Context)
```
Load 20 files × 250 lines = 5000 tokens per task
Cost: $0.10 per task (at $0.02/1k tokens)
```

### SSD (Dynamic Context)
```
Load 10 patterns × 150 lines = 1500 tokens per task
Cost: $0.03 per task
Savings: 70% token reduction
```

**Plus:** Better quality because patterns are weighted by actual success, not static priority.

---

## Example: Context Loading Evolution

### Task 1: "Create API endpoint"
```
No history → Load generic patterns:
- api-patterns.md (250 tokens)
- validation.md (200 tokens)
- error-handling.md (150 tokens)
Total: 600 tokens
Result: Generic code, needs refactoring
```

### Task 10: "Create API endpoint" (after learning)
```
Similar tasks found: 8 successful API endpoints
Top patterns:
1. zod-validation (weight: 0.95) - 120 tokens
2. drizzle-orm (weight: 0.87) - 100 tokens
3. nextjs-app-router (weight: 0.92) - 150 tokens
4. error-response-format (weight: 0.88) - 80 tokens
Total: 450 tokens
Result: Code matches project patterns exactly, no refactoring
```

---

## Configuration

### Context Sources Priority
```yaml
context_sources:
  - local_project: ".opencode/context/project-intelligence/"  # Highest
  - team_shared: ".opencode/context/team/"  # Shared across team
  - global: "~/.config/opencode/context/"  # Global defaults
  - learned: "context/patterns/"  # Auto-generated patterns
```

### Minimum Context Requirements
```yaml
always_include:
  - system_prompt  # Core agent instructions
  - task_template  # Current task structure
  - safety_rules   # Security constraints

min_context_tokens: 500
max_context_tokens: 3000
```

---

*Dynamic context loading reduces tokens by 70% while improving code quality through weighted pattern selection.*
