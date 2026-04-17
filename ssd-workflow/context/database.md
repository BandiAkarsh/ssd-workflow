# Database Patterns

**Purpose**: Define patterns for database design, queries, and migrations
**Version**: 1.0.0

---

## 🎯 Database Principles

| Principle | Description |
|-----------|-------------|
| **Normalize** | Reduce redundancy, ensure integrity |
| **Index Wisely** | Optimize for query patterns |
| **Migrate Safely** | Version schema changes |
| **Seed Carefully** | Test data for development |

---

## 🏗️ Schema Design Patterns

### Primary Key Selection
```sql
-- ✅ GOOD: UUID for distributed systems
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ✅ GOOD: Auto-increment for simple cases
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT
);
```

### Relationships
```sql
-- One-to-Many
CREATE TABLE authors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    author_id INT REFERENCES authors(id),
    title VARCHAR(255) NOT NULL
);

-- Many-to-Many (junction table)
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE enrollments (
    student_id INT REFERENCES students(id),
    course_id INT REFERENCES courses(id),
    enrolled_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (student_id, course_id)
);
```

---

## 📝 Query Patterns

### Parameterized Queries (Prevent SQL Injection)
```typescript
// ✅ GOOD: Parameterized
const query = 'SELECT * FROM users WHERE email = $1';
const result = await db.query(query, [email]);

// ❌ BAD: String concatenation
const query = `SELECT * FROM users WHERE email = '${email}'`;
```

### Pagination
```sql
SELECT * FROM posts
ORDER BY created_at DESC
LIMIT 20 OFFSET 40;  -- Page 3 (20 per page)
```

---

## 🔄 Migration Patterns

### Safe Migration Workflow
```typescript
// 1. Add new column as nullable
await db.query(`
    ALTER TABLE users ADD COLUMN phone VARCHAR(20)
`);

// 2. Backfill data
await db.query(`
    UPDATE users SET phone = 'unknown' WHERE phone IS NULL
`);

// 3. Add constraints
await db.query(`
    ALTER TABLE users ALTER COLUMN phone SET NOT NULL
`);
```

### Rollback Pattern
```typescript
// Always keep migration reversible
export async function up(): Promise<void> {
    await db.query('ALTER TABLE users ADD COLUMN age INT');
}

export async function down(): Promise<void> {
    await db.query('ALTER TABLE users DROP COLUMN age');
}
```

---

## ⚡ Performance Patterns

### Indexing Strategy
```sql
-- Index for WHERE clauses
CREATE INDEX idx_users_email ON users(email);

-- Index for JOINs
CREATE INDEX idx_books_author ON books(author_id);

-- Composite index for queries with multiple conditions
CREATE INDEX idx_orders_status_date ON orders(status, created_at DESC);

-- Partial index for common filters
CREATE INDEX idx_posts_published ON posts(published_at) 
WHERE status = 'published';
```

### Query Optimization
```sql
-- ❌ BAD: N+1 query pattern
SELECT * FROM orders;
-- Then for each order:
SELECT * FROM users WHERE id = order.user_id;

-- ✅ GOOD: JOIN when needed
SELECT o.*, u.name as customer_name
FROM orders o
JOIN users u ON o.user_id = u.id;
```

---

## 🛡️ Data Safety

### Soft Delete Pattern
```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    deleted_at TIMESTAMP DEFAULT NULL
);

-- Query always filters deleted
SELECT * FROM products WHERE deleted_at IS NULL;

-- Soft delete
UPDATE products SET deleted_at = NOW() WHERE id = 1;
```

### Audit Trail
```sql
CREATE TABLE audit_log (
    id BIGSERIAL PRIMARY KEY,
    table_name VARCHAR(100),
    record_id INT,
    action VARCHAR(20),
    old_data JSONB,
    new_data JSONB,
    changed_by INT,
    changed_at TIMESTAMP DEFAULT NOW()
);
```

---

## 🧪 Testing with Databases

### Test Database Setup
```typescript
beforeAll(async () => {
    // Create fresh test database
    await createTestDb();
    
    // Run migrations
    await runMigrations(testDb);
    
    // Seed test data
    await seedTestData(testDb);
});

afterAll(async () => {
    await dropTestDb();
});
```

---

*Database patterns v1.0.0 - Updated 2026-04-17*