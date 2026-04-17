# Deployment and DevOps Patterns

**Purpose**: Define patterns for deployment, infrastructure, and operations
**Version**: 1.0.0

---

## 🚀 Deployment Strategies

### Blue-Green Deployment
```
┌─────────────────┐     ┌─────────────────┐
│   Blue (Live)   │     │  Green (New)    │
│     v1.0.0      │     │     v1.1.0      │
└────────┬────────┘     └────────┬────────┘
         │                        │
         │    Traffic Switch      │
         └───────────┬────────────┘
                     │
              ┌──────▼──────┐
              │   Load      │
              │   Balancer  │
              └─────────────┘
```

### Canary Deployment
```yaml
canary:
  steps:
    - weight: 10%  # 10% traffic to new version
    - wait: 5m     # Monitor for issues
    - weight: 25%  # Increase to 25%
    - wait: 10m
    - weight: 50%  # Half traffic
    - wait: 15m
    - weight: 100% # Full rollout
    - action: promote
```

---

## 📦 Container Patterns

### Dockerfile Best Practices
```dockerfile
# ✅ Multi-stage build for smaller images
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# ✅ Minimal runtime image
FROM node:20-alpine AS runtime
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

# ✅ Non-root user for security
USER node
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

### Docker Compose for Development
```yaml
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
    volumes:
      - .:/app
      - /app/node_modules
    depends_on:
      - db
      - redis

  db:
    image: postgres:15-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=dev

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
```

---

## ☁️ Cloud Infrastructure

### Kubernetes Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ssd-workflow
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ssd-workflow
  template:
    metadata:
      labels:
        app: ssd-workflow
    spec:
      containers:
      - name: app
        image: ssd-workflow:latest
        ports:
        - containerPort: 3000
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
```

---

## 🔄 CI/CD Pipeline

### GitHub Actions Example
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install
        run: npm ci
      
      - name: Lint
        run: npm run lint
      
      - name: Type Check
        run: npm run type-check
      
      - name: Test
        run: npm run test:coverage
      
      - name: Build
        run: npm run build

  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to Production
        run: |
          # Deployment commands
```

---

## 📊 Monitoring Patterns

### Health Check Endpoints
```typescript
// Liveness probe - is the app running?
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Readiness probe - can the app serve traffic?
app.get('/ready', async (req, res) => {
    const checks = await Promise.all([
        checkDatabase(),
        checkRedis(),
        checkExternalAPIs()
    ]);
    
    const allReady = checks.every(c => c.ready);
    res.status(allReady ? 200 : 503).json({
        ready: allReady,
        checks
    });
});
```

### Metrics Collection
```typescript
// Request metrics
const requestDuration = new Histogram({
    name: 'http_request_duration_ms',
    help: 'HTTP request duration in milliseconds',
    buckets: [50, 100, 250, 500, 1000, 2500, 5000]
});

// Usage
app.use((req, res, next) => {
    const start = Date.now();
    res.on('finish', () => {
        requestDuration.observe(Date.now() - start);
    });
    next();
});
```

---

## 🔒 Security in Deployment

### Secret Management
```yaml
# ❌ NEVER commit secrets
# .env file (add to .gitignore!)
DATABASE_PASSWORD=secret123

# ✅ Use secret management
env:
  - name: DATABASE_PASSWORD
    valueFrom:
      secretKeyRef:
        name: db-credentials
        key: password
```

---

## 🔄 Self-Healing Infrastructure

This file updates with infrastructure learnings and new cloud patterns.

*Deployment patterns v1.0.0 - Updated 2026-04-17*