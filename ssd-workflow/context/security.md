# Security Standards and Best Practices

**Purpose**: Define security patterns for all SSD-generated code
**Version**: 1.0.0

---

## 🛡️ Core Security Principles

| Principle | Description | Implementation |
|-----------|-------------|----------------|
| **Defense in Depth** | Multiple layers of security | Validate at every boundary |
| **Least Privilege** | Minimal permissions needed | Request only required access |
| **Fail Secure** | Default to deny on failure | Block on error, don't leak |
| **Audit Everything** | Log all security events | Immutable audit trails |

---

## 🔐 Authentication Patterns

### Secure Token Handling
```typescript
// ✅ GOOD: Token storage in memory, HttpOnly cookies
function login(credentials: Credentials): AuthToken {
    const token = await authService.authenticate(credentials);
    
    // Store in memory only (not localStorage)
    session.set('authToken', token.value, {
        httpOnly: true,
        secure: true,
        sameSite: 'strict',
        maxAge: token.expiresIn
    });
    
    return token;
}

// ❌ BAD: LocalStorage is vulnerable to XSS
localStorage.setItem('token', token);  // NEVER DO THIS
```

### Password Requirements
```typescript
interface PasswordPolicy {
    minLength: 12;
    requireUppercase: true;
    requireLowercase: true;
    requireNumbers: true;
    requireSymbols: true;
    maxAge: 90; // days
    preventReuse: 12; // previous passwords
}

function validatePassword(password: string, policy: PasswordPolicy): ValidationResult {
    const checks = [
        { valid: password.length >= policy.minLength, message: 'Too short' },
        { valid: /[A-Z]/.test(password), message: 'Need uppercase' },
        { valid: /[a-z]/.test(password), message: 'Need lowercase' },
        { valid: /[0-9]/.test(password), message: 'Need number' },
        { valid: /[!@#$%^&*]/.test(password), message: 'Need symbol' }
    ];
    
    if (checks.some(c => !c.valid)) {
        throw new ValidationError(checks.filter(c => !c.valid).map(c => c.message));
    }
    
    return { valid: true };
}
```

---

## 🛡️ Input Validation

### SQL Injection Prevention
```typescript
// ❌ BAD: String concatenation
const query = "SELECT * FROM users WHERE id = " + userId;

// ✅ GOOD: Parameterized queries
const query = "SELECT * FROM users WHERE id = $1";
const result = await db.query(query, [userId]);

// ✅ GOOD: ORM/Query Builder
const user = await db.users.findById(userId);
```

### XSS Prevention
```typescript
// ❌ BAD: Direct HTML injection
element.innerHTML = userInput;

// ✅ GOOD: Text content
element.textContent = userInput;

// ✅ GOOD: Sanitized HTML (when needed)
import DOMPurify from 'dompurify';
element.innerHTML = DOMPurify.sanitize(userInput);
```

### Command Injection Prevention
```typescript
// ❌ BAD: User input in shell command
exec('grep ' + userInput + ' file.txt');

// ✅ GOOD: Sanitized arguments
execFile('grep', [userInput, 'file.txt']);

// ✅ GOOD: Use APIs instead of shell
const results = await grepAPI.search({ pattern: userInput, file: 'file.txt' });
```

---

## 📊 Authorization Patterns

### RBAC Implementation
```typescript
type Permission = 'read' | 'write' | 'delete' | 'admin';
type Role = 'user' | 'editor' | 'admin' | 'superadmin';

const rolePermissions: Record<Role, Permission[]> = {
    user: ['read'],
    editor: ['read', 'write'],
    admin: ['read', 'write', 'delete'],
    superadmin: ['read', 'write', 'delete', 'admin']
};

function checkPermission(role: Role, permission: Permission): boolean {
    return rolePermissions[role]?.includes(permission) ?? false;
}

// Middleware usage
function requirePermission(permission: Permission) {
    return (req: Request, res: Response, next: NextFunction) => {
        const user = req.user;
        if (!user || !checkPermission(user.role, permission)) {
            return res.status(403).json({ error: 'Forbidden' });
        }
        next();
    };
}
```

---

## 🔒 Data Protection

### Encryption at Rest
```typescript
import { createCipheriv, randomBytes } from 'crypto';

interface EncryptedData {
    iv: string;
    data: string;
    tag: string;
}

function encrypt(plaintext: string, key: string): EncryptedData {
    const iv = randomBytes(16);
    const cipher = createCipheriv('aes-256-gcm', Buffer.from(key, 'hex'), iv);
    
    let encrypted = cipher.update(plaintext, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    const tag = cipher.getAuthTag();
    
    return {
        iv: iv.toString('hex'),
        data: encrypted,
        tag: tag.toString('hex')
    };
}
```

### Sensitive Data Handling
```typescript
// Log sanitization - NEVER log sensitive data
function sanitizeForLogging(data: Record<string, unknown>): Record<string, unknown> {
    const sensitiveKeys = ['password', 'token', 'secret', 'key', 'ssn', 'creditCard'];
    
    const sanitized: Record<string, unknown> = {};
    for (const [key, value] of Object.entries(data)) {
        if (sensitiveKeys.some(sk => key.toLowerCase().includes(sk))) {
            sanitized[key] = '[REDACTED]';
        } else {
            sanitized[key] = value;
        }
    }
    
    return sanitized;
}
```

---

## 🔍 Security Monitoring

### Audit Logging
```typescript
interface AuditEvent {
    timestamp: string;
    userId: string;
    action: string;
    resource: string;
    result: 'success' | 'failure';
    ipAddress: string;
    userAgent: string;
}

async function logAuditEvent(event: AuditEvent): Promise<void> {
    // Async write to audit log (not blocking)
    await auditLog.write({
        ...event,
        timestamp: new Date().toISOString(),
        // Never log sensitive data
    });
}
```

---

## 🔄 Self-Updating Security Rules

This file updates automatically when:
1. New CVE discovered affecting our stack
2. Security audit finds patterns to add
3. Developer reports security improvement

*Last updated: 2026-04-17*