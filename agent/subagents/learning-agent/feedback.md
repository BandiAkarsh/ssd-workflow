---
description: "Learn from human feedback and corrections to improve future tasks"
version: "0.1.0"
---

# Learning Agent - Feedback System

Captures, processes, and applies human feedback to continuously improve the SSD workflow.

---

## Learning Philosophy

**"Every human interaction is a training opportunity."**

The system learns from:
1. **Explicit feedback** - Human ratings, corrections, comments
2. **Implicit feedback** - Approval/rejection, edit patterns, time spent
3. **Outcomes** - Success/failure of generated code in production
4. **Comparisons** - Which of multiple options human chose

---

## Feedback Collection Points

### 1. Post-Execution Review
```javascript
// After agent completes task, human reviews:
if (task.needsReview) {
  const feedback = await askHuman({
    task: task.description,
    code: task.result,
    questions: [
      { type: "rating", scale: 1-5, question: "Quality of code?" },
      { type: "choice", options: ["excellent", "good", "needs_work", "poor"], question: "Overall assessment?" },
      { type: "text", question: "What should be improved?" },
      { type: "corrections", question: "Paste corrected code if needed" }
    ]
  });
  
  await learningAgent.recordFeedback(task, feedback);
}
```

### 2. Correction Detection
```javascript
// Automatically detect when human modifies agent output
const original = getAgentOutput(taskId);
const modified = getHumanModifiedCode(taskId);

if (original !== modified) {
  const diff = generateDiff(original, modified);
  const corrections = analyzeDiff(diff);
  
  await learningAgent.recordCorrection({
    task: task.description,
    original,
    modified,
    diff,
    corrections,
    inferredReason: await inferCorrectionReason(diff)
  });
}
```

### 3. Approval Pattern Learning
```javascript
// Track what gets auto-approved vs needs review
if (task.autonomyLevel === 1 && human.quickApproved) {
  // High confidence → auto-approved → reinforce pattern
  await learningAgent.reinforcePattern(task.patternsUsed);
}

if (task.humanRequestedChanges) {
  // Human made changes → adjust weights
  await learningAgent.penalizePatterns(task.patternsUsed);
}
```

### 4. Model Performance Tracking
```javascript
// Track which models succeed/fail for which tasks
await learningAgent.recordModelPerformance({
  task: task.description,
  taskType: task.type,
  model: task.modelUsed,
  success: task.success,
  confidence: task.confidence,
  humanIntervention: task.humanIntervention,
  tokensUsed: task.tokens,
  latency: task.latency
});
```

---

## Feedback Processing Pipeline

### Step 1: Categorization
```javascript
function categorizeFeedback(feedback) {
  const categories = [];
  
  if (feedback.codeCorrections) {
    categories.push({
      type: "code_correction",
      severity: inferSeverity(feedback.codeCorrections),
      patterns: extractPatterns(feedback.codeCorrections)
    });
  }
  
  if (feedback.rating < 3) {
    categories.push({
      type: "low_rating",
      severity: "high",
      aspects: identifyLowAspects(feedback)
    });
  }
  
  if (feedback.comments.includes("security")) {
    categories.push({
      type: "security_concern",
      severity: "critical",
      patterns: extractSecurityPatterns(feedback)
    });
  }
  
  return categories;
}
```

### Step 2: Pattern Extraction
```javascript
function extractLearningPatterns(correction) {
  const patterns = [];
  
  // Example: Human changes zod to yup
  if (correction.includes('z.object') && correction.includes('yup.object')) {
    patterns.push({
      type: "validation_library_preference",
      from: "zod",
      to: "yup",
      context: correction.context,  // "validation tasks"
      confidence: 0.9
    });
  }
  
  // Example: Human adds error handling
  if (correction.addedTryCatch) {
    patterns.push({
      type: "error_handling_required",
      where: "async_functions",
      pattern: "try-catch-with-logging",
      confidence: 0.85
    });
  }
  
  return patterns;
}
```

### Step 3: Weight Adjustment
```javascript
async function adjustWeights(learnings) {
  for (const learning of learnings) {
    switch (learning.type) {
      case "pattern_success":
        // Pattern worked → increase weight
        const current = getWeight(learning.pattern);
        const newWeight = Math.min(1.0, current + 0.05);
        setWeight(learning.pattern, newWeight);
        break;
      
      case "pattern_failure":
        // Pattern failed → decrease weight
        const current = getWeight(learning.pattern);
        const newWeight = Math.max(0.1, current - 0.1);
        setWeight(learning.pattern, newWeight);
        break;
      
      case "preference_shift":
        // Human prefers alternative → swap weights
        const fromWeight = getWeight(learning.from);
        const toWeight = getWeight(learning.to);
        setWeight(learning.from, toWeight * 0.8);  // Downgrade
        setWeight(learning.to, fromWeight * 1.2);  // Upgrade
        break;
    }
  }
}
```

### Step 4: Strategy Update
```javascript
// If self-healing strategy failed, try different approach
if (learning.type === "self_heal_failed") {
  const errorType = learning.errorType;
  const strategy = learning.strategy;
  
  // Decrease success rate for this strategy
  updateStrategySuccessRate(errorType, strategy, success: false);
  
  // If human used different fix, add it as new strategy
  if (learning.humanFix) {
    addStrategy(errorType, learning.humanFix, confidence: 0.9);
  }
}
```

---

## Learning Storage

### Pattern Success Database
```yaml
# context/learning/pattern-success.yaml
patterns:
  zod-validation:
    total_uses: 47
    successful_uses: 47
    human_approved: 45
    auto_approved: 2
    avg_confidence: 0.92
    last_30d_uses: 47
    last_30d_success: 47
    trend: "improving"
  
  custom-hook-auth:
    total_uses: 5
    successful_uses: 3
    human_approved: 1
    auto_approved: 2
    avg_confidence: 0.65
    corrections: 2
    common_correction: "use-use-auth-hook-instead"
    trend: "declining"
```

### Human Corrections Database
```yaml
# context/learning/corrections.yaml
corrections:
  - id: "corr-001"
    task: "Create login API endpoint"
    pattern: "zod-validation"
    original: |
      const data = await request.json();
      // No validation
    corrected: |
      const schema = z.object({ email: z.string().email() });
      const data = schema.parse(await request.json());
    reason: "missing_input_validation"
    severity: "high"
    timestamp: 2026-04-17T10:30:00Z
  
  - id: "corr-002"
    task: "Build user dashboard"
    pattern: "component-structure"
    original: |
      export default function Dashboard() {
        const [users, setUsers] = useState([]);
        // Direct fetch in component
      }
    corrected: |
      export default function Dashboard() {
        const { data: users, error } = useSWR('/api/users');
        // Use SWR for data fetching
      }
    reason: "use_swr_for_data_fetching"
    severity: "medium"
```

### Model Performance Database
```yaml
# context/learning/model-performance.yaml
models:
  claude-opus-4:
    tasks:
      architecture: { count: 15, avg_confidence: 0.88, human_intervention: 0.07 }
      security: { count: 8, avg_confidence: 0.92, human_intervention: 0.0 }
      implementation: { count: 23, avg_confidence: 0.85, human_intervention: 0.13 }
  
  gpt-4o-mini:
    tasks:
      testing: { count: 42, avg_confidence: 0.78, human_intervention: 0.21 }
      documentation: { count: 18, avg_confidence: 0.82, human_intervention: 0.11 }
      implementation: { count: 5, avg_confidence: 0.62, human_intervention: 0.4 }  # Poor!
```

---

## Learning Applications

### 1. Smarter Context Loading
```javascript
// Before: Load all patterns with weight > 0.5
// After: Also boost patterns that human recently corrected

const recentCorrections = getRecentCorrections(days: 7);
const boostedPatterns = recentCorrections.map(c => c.pattern);

const patternsToLoad = topPatterns.map(p => {
  if (boostedPatterns.includes(p.id)) {
    p.weight = Math.min(1.0, p.weight * 1.2);  // Temporary boost
  }
  return p;
});
```

### 2. Adaptive Approval Thresholds
```javascript
// If human frequently overrides auto-approvals, raise threshold
const overrideRate = getAutoApprovalOverrideRate();
if (overrideRate > 0.3) {
  // 30% of auto-approvals overridden → too aggressive
  setConfidenceThreshold(0.95);  // Require higher confidence
}

if (overrideRate < 0.05) {
  // Very few overrides → can lower threshold
  setConfidenceThreshold(0.85);  // More auto-approvals
}
```

### 3. Model Routing Optimization
```javascript
// If model consistently performs poorly on task type, reroute
for (const [model, performance] of modelPerformance) {
  for (const [taskType, stats] of performance.tasks) {
    if (stats.human_intervention > 0.3 && stats.count > 10) {
      // This model needs human help >30% on this task type
      // Downgrade priority for this task type
      updateRoute(taskType, { downgrade: model });
    }
    
    if (stats.avg_confidence > 0.9 && stats.human_intervention < 0.05) {
      // Excellent performance, upgrade priority
      updateRoute(taskType, { upgrade: model });
    }
  }
}
```

### 4. Self-Healing Strategy Optimization
```javascript
// Track which self-heal strategies work
const strategySuccess = getStrategySuccessRates();

for (const [errorType, strategies] of strategySuccess) {
  // Sort strategies by success rate
  const sorted = strategies.sort((a, b) => b.successRate - a.successRate);
  
  // Update policy to use best strategy first
  updateSelfHealPolicy(errorType, {
    attemptOrder: sorted.map(s => s.strategy),
    fallback: sorted[sorted.length - 1].strategy
  });
}
```

---

## Team Learning

### Shared Learning Database
```yaml
# Shared across team in .opencode/context/learning/
# Committed to git, synced for all developers

team_learnings:
  - pattern: "validation-library"
    preference: "zod"
    confidence: 0.95
    agreed_by: 8/10 developers
    last_updated: 2026-04-17
  
  - pattern: "component-structure"
    standard: "shadcn-ui"
    compliance: 0.98
    deviations: 2  # Only 2 exceptions in last 50 tasks
```

### Onboarding New Developers
```javascript
// New developer joins → load team patterns
const teamPatterns = getTeamStandardPatterns();
const commonMistakes = getTeamCommonMistakes();

// Auto-context includes:
// - Team standards (high weight)
// - Common mistakes to avoid (negative patterns)
// - Preferred approaches (positive patterns)
```

---

## Feedback UI/Commands

### Inline Feedback
```bash
# After task completion, agent prompts:
Rate this code (1-5): 4
What needs improvement? "Add error handling for network failures"
# System learns: "network error handling required for API calls"

# Or provide corrected code:
/correct --task 123 --file src/api/user.ts --reason "missing-error-handling"
```

### Batch Feedback
```bash
# Review last week's tasks
./scripts/learning/review-week.sh

# Shows:
# - Tasks with low ratings
# - Common correction patterns
# - Model performance summary
# - Suggested pattern updates

# Approve/deny suggested updates
./scripts/learning/apply-updates.sh --approved
```

---

## Metrics & Dashboards

### Learning Health Metrics
```yaml
learning_metrics:
  feedback_rate: "85%"  # % tasks with feedback
  correction_rate: "12%"  # % tasks needing corrections
  pattern_updates_week: 15  # Patterns adjusted weekly
  model_reroutes_month: 3  # Model routes changed
  self_heal_improvement: "+15%"  # Self-heal rate improved
  
  top_learned_patterns:
    - pattern: "use-swr-for-data-fetching"
      boost: +0.25
      reason: "human preference"
    - pattern: "zod-over-yup"
      boost: +0.18
      reason: "team standard"
  
  declining_patterns:
    - pattern: "custom-error-handling"
      penalty: -0.12
      reason: "use-standard-errors-instead"
```

### Visualization
```bash
# Generate learning report
./scripts/learning/generate-report.sh --period week

# Output:
# - Pattern weight changes
# - Model performance trends
# - Common corrections
# - Autonomy score trend
# - Token efficiency improvement
```

---

## Advanced: Predictive Learning

### Predict Human Preferences
```javascript
// Based on past feedback, predict what human will want
const predictions = await predictHumanPreferences(task);
// Returns:
// {
//   likelyApproval: false,
//   probableCorrections: [
//     { pattern: "error-handling", confidence: 0.8 },
//     { pattern: "validation", confidence: 0.6 }
//   ],
//   suggestedPreEmptiveFixes: [
//     "add-try-catch",
//     "add-zod-schema"
//   ]
// }

// Apply pre-emptive fixes before human sees
if (predictions.suggestedPreEmptiveFixes) {
  await applyPreEmptiveFixes(predictions.suggestedPreEmptiveFixes);
}
```

### A/B Testing Patterns
```javascript
// Test two patterns against each other
if (uncertainWhichPattern(task)) {
  // Split task into two variants
  const variantA = await generateWithPattern(task, patternA);
  const variantB = await generateWithPattern(task, patternB);
  
  // Ask human: "Which is better?"
  const choice = await askHumanPreference(variantA, variantB);
  
  // Learn from choice
  if (choice === 'A') {
    boostPattern(patternA);
    penalizePattern(patternB);
  } else {
    boostPattern(patternB);
    penalizePattern(patternA);
  }
}
```

---

*Learning transforms SSD from static automation to adaptive intelligence, improving with every human interaction.*
