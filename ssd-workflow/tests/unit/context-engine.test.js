const { analyzeTaskForContext, calculatePatternWeight } = require('../agent/subagents/context-engine/analyzer');

describe('Context Engine - Analyzer', () => {
  test('should classify task type correctly', async () => {
    const task = {
      description: 'Create a new API endpoint for user authentication',
      type: 'implementation'
    };
    
    const result = await analyzeTaskForContext(task);
    
    expect(result.patterns).toBeDefined();
    expect(result.weights).toBeDefined();
    expect(result.estimatedTokens).toBeLessThan(3000);
  });
  
  test('should weight patterns by success rate', () => {
    const pattern = {
      id: 'zod-validation',
      usageCount: 47,
      successRate: 1.0,
      lastUsed: new Date(),
      humanApproved: true
    };
    
    const weight = calculatePatternWeight(pattern);
    expect(weight).toBeGreaterThan(0.9);
  });
  
  test('should penalize patterns with low success', () => {
    const pattern = {
      id: 'custom-error-handling',
      usageCount: 10,
      successRate: 0.6,
      lastUsed: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000), // 10 days ago
      humanApproved: false
    };
    
    const weight = calculatePatternWeight(pattern);
    expect(weight).toBeLessThan(0.5);
  });
});
