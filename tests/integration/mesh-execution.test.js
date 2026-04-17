const { buildDependencyGraph, createBatches } = require('../agent/orchestrator/mesh');

describe('Parallel Execution Mesh', () => {
  const sampleTasks = [
    { id: 'api', deps: [] },
    { id: 'db', deps: [] },
    { id: 'ui', deps: ['api'] },
    { id: 'tests', deps: ['api', 'db', 'ui'] }
  ];
  
  test('should build correct dependency graph', () => {
    const graph = buildDependencyGraph(sampleTasks);
    
    expect(graph.nodes.size).toBe(4);
    expect(graph.nodes.get('api').deps).toEqual([]);
    expect(graph.nodes.get('ui').deps).toEqual(['api']);
    expect(graph.nodes.get('tests').deps).toEqual(['api', 'db', 'ui']);
  });
  
  test('should create optimal batches', () => {
    const graph = buildDependencyGraph(sampleTasks);
    const batches = createBatches(graph);
    
    // Batch 1: api, db (no deps)
    // Batch 2: ui (depends on api)
    // Batch 3: tests (depends on everything)
    expect(batches.length).toBe(3);
    expect(batches[0]).toContain('api');
    expect(batches[0]).toContain('db');
    expect(batches[1]).toContain('ui');
    expect(batches[2]).toContain('tests');
  });
  
  test('should detect circular dependencies', () => {
    const circularTasks = [
      { id: 'a', deps: ['b'] },
      { id: 'b', deps: ['a'] }
    ];
    
    const graph = buildDependencyGraph(circularTasks);
    expect(() => createBatches(graph)).toThrow('Circular dependency');
  });
});
