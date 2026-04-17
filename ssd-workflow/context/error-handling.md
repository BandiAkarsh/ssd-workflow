# Error Handling Patterns

**Purpose**: Define consistent error handling across SSD
**Version**: 1.0.0

---

## 🎯 Error Handling Principles

| Principle | Description |
|-----------|-------------|
| **Fail Fast** | Validate early, fail clearly |
| **Fail Safe** | Don't leak sensitive data |
| **Log Context** | Include enough info for debugging |
| **Recover Gracefully** | Provide fallback behavior |

---

## 🔧 Error Class Hierarchy

### Base Error Classes
```typescript
// Application error base
class AppError extends Error {
    constructor(
        message: string,
        public code: string,
        public statusCode: number = 500,
        public details?: unknown
    ) {
        super(message);
        this.name = this.constructor.name;
        Error.captureStackTrace(this, this.constructor);
    }
}

// Specific error types
class ValidationError extends AppError {
    constructor(message: string, details?: unknown) {
        super(message, 'VALIDATION_ERROR', 400, details);
    }
}

class NotFoundError extends AppError {
    constructor(resource: string, identifier: string) {
        super(`${resource} not found: ${identifier}`, 'NOT_FOUND', 404);
    }
}

class UnauthorizedError extends AppError {
    constructor(message = 'Unauthorized') {
        super(message, 'UNAUTHORIZED', 401);
    }
}

class ConflictError extends AppError {
    constructor(message: string) {
        super(message, 'CONFLICT', 409);
    }
}
```

---

## 📝 Error Handling Middleware

### Express/Node Middleware
```typescript
function errorHandler(
    err: Error,
    req: Request,
    res: Response,
    next: NextFunction
): void {
    // Log error with context
    logger.error('Request failed', {
        error: err.message,
        stack: process.env.NODE_ENV !== 'production' ? err.stack : undefined,
        path: req.path,
        method: req.method,
        userId: req.user?.id
    });

    // Handle known error types
    if (err instanceof AppError) {
        res.status(err.statusCode).json({
            success: false,
            error: {
                code: err.code,
                message: err.message,
                details: err.details
            }
        });
        return;
    }

    // Unknown error - don't leak internal details
    res.status(500).json({
        success: false,
        error: {
            code: 'INTERNAL_ERROR',
            message: 'An unexpected error occurred'
        }
    });
}
```

---

## 🔄 Recovery Patterns

### Retry with Backoff
```typescript
async function retry<T>(
    fn: () => Promise<T>,
    options: {
        maxRetries: number;
        initialDelay: number;
        maxDelay: number;
        backoffMultiplier: number;
    }
): Promise<T> {
    let lastError: Error;
    let delay = options.initialDelay;

    for (let attempt = 0; attempt <= options.maxRetries; attempt++) {
        try {
            return await fn();
        } catch (error) {
            lastError = error as Error;
            
            if (attempt < options.maxRetries) {
                await sleep(delay);
                delay = Math.min(
                    delay * options.backoffMultiplier,
                    options.maxDelay
                );
            }
        }
    }

    throw lastError;
}
```

### Fallback Pattern
```typescript
async function getData(): Promise<Data> {
    try {
        // Try primary source
        return await primarySource.get();
    } catch (error) {
        logger.warn('Primary source failed, trying cache', { error });
        
        try {
            // Fallback to cache
            return await cache.get();
        } catch (cacheError) {
            logger.error('All sources failed', { error, cacheError });
            throw new DataUnavailableError();
        }
    }
}
```

---

## 🧪 Testing Errors

```typescript
// Test error throwing
expect(() => validateEmail('')).toThrow(ValidationError);

// Test error properties
expect(() => validateEmail('invalid')).toThrow({
    name: 'ValidationError',
    code: 'INVALID_EMAIL'
});
```

---

*Error handling patterns v1.0.0 - Updated 2026-04-17*