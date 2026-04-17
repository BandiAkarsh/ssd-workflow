---
description: "Parallel agent coordination and execution mesh"
version: "0.1.0"
---

# Parallel Execution Mesh

Coordinates multiple agents executing simultaneously with intelligent dependency resolution and cross-agent communication.

---

## Core Concept

Instead of sequential execution (Agent A → Agent B → Agent C), the mesh executes:

```
Batch 1 (Parallel):
  ├─ Agent A (API endpoints)
  ├─ Agent B (Database schema)
  └─ Agent C (UI components)
        ↓ All complete
Batch 2 (Sequential):
  └─ Agent D (Integration tests)
```

**Key Innovation:** Agents communicate mid-execution to share discoveries, avoiding duplicate work and ensuring consistency.

---

## Dependency Graph Builder

### Input: Task Decomposition
```javascript
const task = {
  description: "Build e-commerce checkout",
  subtasks: [
    { id: "api-checkout", description: "POST /api/checkout", deps: [] },
    { id: "db-orders", description: "orders table", deps: [] },
    { id: "db-products", description: "products table", deps: [] },
    { id: "payment-integration", description: "Stripe integration", deps: ["api-checkout"] },
    { id: "checkout-ui", description: "Checkout page", deps: ["api-checkout", "db-products"] },
    { id: "tests", description: "Checkout tests", deps: ["api-checkout", "db-orders", "payment-integration", "checkout-ui"] }
  ]
};
```

### Graph Construction
```javascript
function buildDependencyGraph(subtasks) {
  const graph = {
    nodes: new Map(),
    edges: []
  };
  
  // Create nodes
  for (const task of subtasks) {
    graph.nodes.set(task.id, {
      id: task.id,
      deps: task.deps,
      dependents: [],
      status: 'pending',
      result: null
    });
  }
  
  // Create edges
  for (const task of subtasks) {
    for (const dep of task.deps) {
      graph.edges.push({ from: dep, to: task.id });
      graph.nodes.get(dep).dependents.push(task.id);
    }
  }
  
  return graph;
}
```

### Batch Detection Algorithm
```javascript
function createBatches(graph) {
  const batches = [];
  const remaining = new Set(graph.nodes.keys());
  
  while (remaining.size > 0) {
    // Find all nodes with no remaining dependencies
    const batch = [];
    for (const nodeId of remaining) {
      const node = graph.nodes.get(nodeId);
      const depsSatisfied = node.deps.every(dep => !remaining.has(dep));
      if (depsSatisfied) {
        batch.push(nodeId);
      }
    }
    
    if (batch.length === 0) {
      throw new Error("Circular dependency detected!");
    }
    
    batches.push(batch);
    for (const nodeId of batch) {
      remaining.delete(nodeId);
    }
  }
  
  return batches;
}

// Result:
// Batch 1: ["api-checkout", "db-orders", "db-products"]  // No deps
// Batch 2: ["payment-integration", "checkout-ui"]        // Depends on Batch 1
// Batch 3: ["tests"]                                     // Depends on Batch 2
```

---

## Parallel Execution Engine

### Execution Loop
```javascript
async function executeMesh(graph, agents) {
  const batches = createBatches(graph);
  const results = {};
  
  for (let batchIndex = 0; batchIndex < batches.length; batchIndex++) {
    const batch = batches[batchIndex];
    console.log(`\n🚀 Executing Batch ${batchIndex + 1}: ${batch.join(', ')}`);
    
    // Execute batch in parallel
    const batchPromises = batch.map(async (taskId) => {
      const task = graph.nodes.get(taskId);
      const agent = agents[taskId];  // Assign specific agent
      
      try {
        // Load context (may include messages from previous agents)
        const context = await loadContextForTask(taskId, results);
        
        // Execute
        const result = await agent.execute(task, context);
        
        // Broadcast result to other agents in same batch
        await broadcastToBatch(taskId, result, batch, results);
        
        // Update graph
        task.status = 'completed';
        task.result = result;
        results[taskId] = result;
        
        return { taskId, success: true, result };
      } catch (error) {
        task.status = 'failed';
        return { taskId, success: false, error };
      }
    });
    
    // Wait for entire batch to complete
    const batchResults = await Promise.all(batchPromises);
    
    // Validate batch completion
    const allSucceeded = batchResults.every(r => r.success);
    if (!allSucceeded) {
      throw new Error(`Batch ${batchIndex + 1} had failures`);
    }
    
    // Cross-batch communication (results from this batch available to next)
    await communicateBatchResults(batch, results);
  }
  
  return results;
}
```

---

## Cross-Agent Communication

### Message Passing
```javascript
// Agent A discovers something useful
agentA.on('discovery', (message) => {
  // message: { to: 'agent-b', type: 'api-spec', content: {...} }
  mesh.communicate(message);
});

// Agent B receives
agentB.on('message', async (msg) => {
  if (msg.type === 'api-spec') {
    // Update local context with discovered API spec
    await contextEngine.update({
      pattern: 'api-endpoint',
      data: msg.content
    });
  }
});
```

### Communication Patterns

**1. Discovery Sharing**
```javascript
// "I found the API should use /api/v1/checkout"
mesh.broadcast({
  from: 'api-agent',
  to: 'all',  // or specific agent
  type: 'api-spec',
  content: { endpoint: '/api/v1/checkout', method: 'POST' },
  priority: 'high'
});
```

**2. Resource Negotiation**
```javascript
// "I need the database user table, when will it be ready?"
mesh.query({
  from: 'ui-agent',
  to: 'db-agent',
  type: 'resource-availability',
  resource: 'user-table',
  neededBy: '2026-04-17T16:00:00Z'
});

// db-agent responds
mesh.respond({
  from: 'db-agent',
  to: 'ui-agent',
  type: 'resource-availability',
  resource: 'user-table',
  readyAt: '2026-04-17T15:45:00Z'
});
```

**3. Conflict Resolution**
```javascript
// "I'm using Zod for validation, what are you using?"
mesh.query({
  from: 'api-agent',
  to: 'test-agent',
  type: 'pattern-check',
  pattern: 'validation-library'
});

// If conflict detected, mesh triggers resolution
mesh.resolveConflict({
  pattern: 'validation-library',
  agents: ['api-agent', 'test-agent'],
  current: ['zod', 'yup'],  // Different libraries
  resolution: 'use_team_standard'  // Check team standards
});
```

---

## Intelligent Result Merging

### Merge Strategies by File Type

**API Endpoints**
```javascript
mergeStrategy: 'union_with_validation'
// Combine all endpoints, ensure no conflicts
// Validate: all routes unique, methods correct
```

**Database Schemas**
```javascript
mergeStrategy: 'dependency_resolution'
// Order by foreign key dependencies
// Apply in correct order to avoid constraint errors
```

**UI Components**
```javascript
mergeStrategy: 'namespace_isolation'
// Each agent's components in separate directories
// No merging needed, just organize
```

**Configuration Files**
```javascript
mergeStrategy: 'deep_merge'
// JSON/YAML deep merge
// Last-write-wins for conflicts, flag for review
```

**Tests**
```javascript
mergeStrategy: 'concatenation_with_deduplication'
// Combine all tests, remove duplicates
// Ensure no test ID conflicts
```

### Merge Implementation
```javascript
async function mergeResults(results, strategy) {
  const merged = {};
  
  switch (strategy) {
    case 'union':
      return Object.assign({}, ...Object.values(results));
    
    case 'deep_merge':
      return deepMerge(...Object.values(results));
    
    case 'concatenation':
      return concatenateArrays(...Object.values(results));
    
    case 'dependency_resolution':
      return resolveByDependencies(results);
    
    case 'namespace_isolation':
      return isolateByNamespace(results);
    
    default:
      throw new Error(`Unknown merge strategy: ${strategy}`);
  }
  
  // Post-merge validation
  const validation = await validateMerged(merged);
  if (!validation.valid) {
    throw new Error(`Merge validation failed: ${validation.errors}`);
  }
  
  return merged;
}
```

---

## Conflict Detection & Resolution

### Common Conflicts

**1. Duplicate File Creation**
```javascript
// Both agents try to create src/components/Button.tsx
conflict: {
  type: 'duplicate_file',
  agents: ['agent-a', 'agent-b'],
  file: 'src/components/Button.tsx',
  resolution: 'merge_with_review'  // Merge, flag for human
}
```

**2. Inconsistent Patterns**
```javascript
// Agent A uses Zod, Agent B uses Yup for validation
conflict: {
  type: 'pattern_inconsistency',
  pattern: 'validation-library',
  values: ['zod', 'yup'],
  resolution: 'apply_team_standard'  // Use team standard
}
```

**3. Dependency Version Mismatch**
```javascript
// Agent A needs React 18, Agent B needs React 17
conflict: {
  type: 'dependency_conflict',
  package: 'react',
  versions: ['^18.0.0', '^17.0.0'],
  resolution: 'use_compatible_version'  // Pick compatible version
}
```

### Resolution Strategies
```javascript
async function resolveConflict(conflict) {
  switch (conflict.type) {
    case 'duplicate_file':
      return await mergeFiles(conflict);
    
    case 'pattern_inconsistency':
      return await applyTeamStandard(conflict);
    
    case 'dependency_conflict':
      return await findCompatibleVersion(conflict);
    
    case 'interface_mismatch':
      return await createAdapter(conflict);
    
    default:
      // Unknown conflict → escalate to human
      await escalateConflict(conflict);
  }
}
```

---

## Error Handling in Mesh

### Agent Failure
```javascript
// If an agent fails in a parallel batch:
if (agentResult.error) {
  // Option 1: Retry with different agent
  if (canRetryWithDifferentAgent(taskId)) {
    const newAgent = getAlternativeAgent(taskId);
    const retryResult = await newAgent.execute(task, context);
    results[taskId] = retryResult;
  }
  
  // Option 2: Decompose task further
  if (taskIsTooComplex(taskId)) {
    const subtasks = await decomposeFurther(taskId);
    // Re-insert into graph, re-run dependency analysis
    await rebalanceGraph(graph, subtasks);
  }
  
  // Option 3: Escalate to human
  await escalateAgentFailure(taskId, agentResult.error);
}
```

### Partial Batch Failure
```javascript
// Some agents in batch succeeded, some failed
const failedTasks = batchResults.filter(r => !r.success);

if (failedTasks.length === batch.length) {
  // All failed → retry entire batch with different models
  await retryBatch(batch, alternativeModels);
} else if (failedTasks.length < batch.length) {
  // Partial failure → continue with successful ones
  // But mark failed ones for manual intervention
  for (const failed of failedTasks) {
    await flagForHuman(failed.taskId, failed.error);
  }
  // Continue to next batch (partial completion)
}
```

---

## Performance Optimization

### Dynamic Parallelism
```javascript
// Don't overload the system
const maxParallel = getAvailableResources().parallelSlots;

if (batch.length > maxParallel) {
  // Split batch into smaller chunks
  const chunks = chunkArray(batch, maxParallel);
  for (const chunk of chunks) {
    await executeChunk(chunk);
  }
} else {
  await executeBatch(batch);
}
```

### Context Sharing
```javascript
// Agents in same batch share context to reduce token usage
const sharedContext = await createSharedContext(batch);
for (const taskId of batch) {
  const agentContext = await customizeContext(sharedContext, taskId);
  await agents[taskId].execute(task, agentContext);
}
```

### Result Caching
```javascript
// Cache identical tasks across different projects
const cacheKey = hash(task.description + task.type);
const cached = await getCachedResult(cacheKey);
if (cached && cacheIsValid(cached)) {
  results[taskId] = cached;
} else {
  results[taskId] = await agent.execute(task);
  await cacheResult(cacheKey, results[taskId]);
}
```

---

## Monitoring & Observability

### Mesh Metrics
```yaml
metrics:
  - parallel_utilization  # % of tasks running in parallel
  - avg_batch_size  # Average tasks per batch
  - cross_agent_messages  # Communication frequency
  - conflict_rate  # % of tasks with conflicts
  - merge_success_rate  # % of merges successful
  - mesh_completion_time  # Total time vs sequential estimate
```

### Visualization
```javascript
// Generate dependency graph for debugging
function visualizeGraph(graph) {
  // Output DOT format for Graphviz
  console.log("digraph G {");
  for (const [nodeId, node] of graph.nodes) {
    console.log(`  "${nodeId}" [status="${node.status}"];`);
    for (const dep of node.deps) {
      console.log(`  "${dep}" -> "${nodeId}";`);
    }
  }
  console.log("}");
}
```

---

## Example: Full Mesh Execution

```
Task: "Build user management feature"

Decomposition:
1. API: /api/users (GET, POST, PUT, DELETE)
2. DB: users table with indexes
3. UI: UserList, UserForm, UserCard components
4. Tests: CRUD operations tests

Dependency Graph:
- API: deps = []
- DB: deps = []
- UI: deps = [API]  // Needs API endpoints defined
- Tests: deps = [API, DB, UI]  // Needs everything

Batches:
Batch 1 (parallel):
  ├─ API (Agent: backend-specialist, Model: claude-sonnet)
  ├─ DB (Agent: database-specialist, Model: gpt-4o)
  └─ UI (Agent: frontend-specialist, Model: claude-sonnet)
        ↓ All complete (2 minutes)
Batch 2 (sequential):
  └─ Tests (Agent: test-engineer, Model: gpt-4o-mini)
        ↓ Waits for Batch 1, then executes (1 minute)

Total: 3 minutes (vs 8 minutes sequential)
Cross-agent comms: API shares endpoint specs with UI and Tests
Conflicts: None (clean separation)
Result: Merged codebase ready for review
```

---

*The mesh enables 3-5x speedup through parallel execution while maintaining coherence through intelligent coordination.*
