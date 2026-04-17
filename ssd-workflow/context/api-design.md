# API Design Patterns

**Purpose**: Define patterns for building robust APIs
**Version**: 1.0.0

---

## 🎯 API Design Principles

| Principle | Description |
|-----------|-------------|
| **RESTful** | Use standard HTTP methods and status codes |
| **Consistent** | Same patterns across all endpoints |
| **Versioned** | Support multiple API versions |
| **Documented** | Auto-generate OpenAPI specs |

---

## 📡 REST Endpoints Pattern

### Resource Naming
```
✅ GOOD: /users /users/:id /users/:id/orders
✅ GOOD: /orders /orders/:id
❌ BAD: /getUsers /getUserOrders /user/order/list
```

### HTTP Methods
| Method | Usage | Idempotent |
|--------|-------|------------|
| GET | Read resources | Yes |
| POST | Create resources | No |
| PUT | Replace entire resource | Yes |
| PATCH | Partial update | No |
| DELETE | Remove resource | Yes |

---

## 📝 Request/Response Patterns

### Standard Response Format
```typescript
interface ApiResponse<T> {
    success: boolean;
    data?: T;
    error?: {
        code: string;
        message: string;
        details?: unknown;
    };
    meta?: {
        page?: number;
        limit?: number;
        total?: number;
    };
}

// Success response
{
    "success": true,
    "data": { "id": "1", "name": "John" }
}

// Error response  
{
    "success": false,
    "error": {
        "code": "USER_NOT_FOUND",
        "message": "User with ID 123 not found"
    }
}
```

### Pagination
```typescript
interface PaginatedRequest {
    page: number;      // Default: 1
    limit: number;    // Default: 20, Max: 100
    sort?: string;    // Field name
    order?: 'asc' | 'desc';
}

interface PaginatedResponse<T> {
    items: T[];
    page: number;
    limit: number;
    total: number;
    hasMore: boolean;
}
```

---

## 🔐 Error Handling

### HTTP Status Codes
```typescript
// Success
200 OK - Request succeeded
201 Created - Resource created
204 No Content - Successful delete

// Client Errors
400 Bad Request - Invalid input
401 Unauthorized - Missing auth
403 Forbidden - No permission
404 Not Found - Resource doesn't exist
409 Conflict - Duplicate resource
422 Unprocessable - Validation failed
429 Too Many Requests - Rate limited

// Server Errors
500 Internal Error - Server issue
503 Unavailable - Maintenance
```

### Error Response Format
```typescript
{
    "success": false,
    "error": {
        "code": "VALIDATION_ERROR",
        "message": "Invalid input data",
        "details": [
            {
                "field": "email",
                "message": "Invalid email format"
            },
            {
                "field": "password",
                "message": "Must be at least 12 characters"
            }
        ]
    }
}
```

---

## 🛡️ Authentication Patterns

### Bearer Token
```typescript
// Request
GET /api/users
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

// Server validation
function authenticate(req: Request): User {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) {
        throw new UnauthorizedError('Missing token');
    }
    
    const token = authHeader.substring(7);
    return jwt.verify(token);
}
```

### API Keys
```typescript
// For service-to-service
X-API-Key: sk_live_abc123...

// Validation
function validateApiKey(key: string): boolean {
    const stored = await getApiKey(key);
    return stored && !stored.revoked;
}
```

---

## 🧪 API Testing

### Contract Testing
```typescript
// Provider test (Pact)
describe('User API', () => {
    it('should return user by id', async () => {
        await provider.addInteraction({
            state: 'user exists',
            uponReceiving: 'a request for user',
            withRequest: {
                method: 'GET',
                path: '/users/1'
            },
            willRespondWith: {
                status: 200,
                body: like({ id: '1', name: 'John' })
            }
        });
    });
});
```

---

## 📖 Documentation

### OpenAPI Specification
```yaml
openapi: 3.0.3
info:
  title: SSD Workflow API
  version: 1.0.0

paths:
  /users:
    get:
      summary: List users
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Users'
```

---

## 🔄 API Evolution

### Versioning Strategy
```
/api/v1/users     → Original
/api/v2/users     → Breaking changes
/api/v3/users     → Latest (recommended)

Header: Accept: application/vnd.ssd.v2+json
```

---

*API patterns v1.0.0 - Updated 2026-04-17*