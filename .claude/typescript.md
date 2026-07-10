# TypeScript Coding Rules

These rules apply when writing or modifying TypeScript code. They take
precedence over your general style instincts. When editing existing code,
match the project's local style if it conflicts — but for new code, follow
these.

## Control flow

### Always brace `if` / `else`

```js
// Good
if (cond) {
    doThing();
} else {
    doOther();
}

// Bad — never write braceless branches, even one-liners
if (cond) doThing();
else doOther();
```

The same applies to `for`, `while`, and `do…while`: always use a block.

### Blank line after `if` / `else` blocks

Keep a single empty line after a closing brace of an `if` or `else`, **unless**
the next statement continues an `if` / `else if` / `else` chain.

```js
// Good — blank line after the chain
if (a) {
    x();
} else if (b) {
    y();
} else {
    z();
}

const next = compute();

// Bad — no blank separator
if (a) {
    x();
}
const next = compute();

// Good — no blank line *inside* the chain
if (a) {
    x();
} else {
    y();
}
```

### Blank line before `return`

Always keep an empty line before a `return` statement, **unless** the return is
the only statement in its block.

```js
// Good
function compute(x) {
    const doubled = x * 2;

    return doubled + 1;
}

// Good — only statement, no leading blank required
function identity(x) {
    return x;
}

// Bad
function compute(x) {
    const doubled = x * 2;
    return doubled + 1;
}
```

### Early returns over `if` / `else` chains

Flatten control flow. Prefer guard clauses and early returns; do not nest when
you can return.

```js
// Good
function classify(user) {
    if (!user) {
        return 'none';
    }

    if (user.banned) {
        return 'banned';
    }

    if (user.admin) {
        return 'admin';
    }

    return 'user';
}

// Bad — unnecessary indentation
function classify(user) {
    if (user) {
        if (user.banned) {
            return 'banned';
        } else {
            if (user.admin) {
                return 'admin';
            } else {
                return 'user';
            }
        }
    } else {
        return 'none';
    }
}
```

Lower indentation is always better. If you find yourself at three levels of
nesting, that's a signal to extract a helper or invert a condition.

## Functions

### Prefer `function` declarations

Use the `function () {}` syntax by default. Reserve arrow functions for two
specific cases:

- Functional-style methods: `.map`, `.filter`, `.reduce`, `.find`, `.flatMap`,
  `.some`, `.every`, `.sort` callbacks, etc.
- Places where lexical `this` is required (rare; usually a class refactor is
  better than an arrow workaround).

```js
// Good
function loadUser(id) {
    return db.users.find(id);
}

const ids = users.map((u) => u.id);

// Bad — arrow used as a top-level definition for no reason
const loadUser = (id) => db.users.find(id);
```

### Error handling — only catch what you can handle

Do not wrap code in `try { … } catch { … }` unless the catch branch does
something meaningful (recover, translate the error, add context, clean up).
Letting an error propagate is the correct default.

```js
// Good — handler adds context
try {
    return await fetchUser(id);
} catch (err) {
    throw new Error(`fetchUser(${id}) failed`, { cause: err });
}

// Bad — swallows or just rethrows
try {
    return await fetchUser(id);
} catch (err) {
    throw err;
}
```

A bare `catch (err) { throw err; }` or `catch { /* nothing */ }` is always wrong.

### Always throw `Error` instances

Never throw raw strings, objects, or other non-`Error` values. Always throw
an `Error` (or a subclass). This guarantees a stack trace is captured at the
throw site.

```ts
// Good
throw new Error('something went wrong');
throw new ValidationError('invalid input', { cause: original });

// Bad
throw 'something went wrong';
throw { code: 'INVALID' };
```

### Handleable vs unhandleable errors

**Handleable (non-critical) errors** — errors the application can recover from
(e.g., a single failed HTTP request in a batch, a malformed user input). Catch
them, **log with full context including the stack trace**, and continue.

**Unhandleable errors** — follow the *let-it-fail* philosophy:

- In application code (e.g., an HTTP server): let the error bubble up to the
  top-most error handler. Return a `500 Internal Server Error` to the client.
  Do not catch and half-handle at intermediate layers.
- Outside application code (CLI tools, workers, scripts): let the process
  crash. A clean crash with a stack trace is better than a half-alive process
  in an unknown state.

### Fail fast — validate on startup

If configuration is wrong, a required port is already in use, a database is
unreachable, or any precondition for healthy operation is violated — **fail
immediately at startup**. Do not start background services, do not open the
HTTP listener, do not accept work. The earlier the failure, the easier the
diagnosis.

```ts
// Good — validate before anything runs
function boot(config: AppConfig) {
    if (!config.databaseUrl) {
        throw new Error('DATABASE_URL is required');
    }

    if (!config.port) {
        throw new Error('PORT is required');
    }

    // Only now start the app…
}
```

### Typed error constructors (factory functions)

For known, expected error conditions define a dedicated `Error` subclass with
a `kind` discriminant, and expose factory functions for each variant. Group
related errors in a module (e.g., `errors/file_system.ts`).

```ts
// errors/file_system.ts

const KIND = {
    NOT_FOUND: 'NOT_FOUND',
    PERMISSION_DENIED: 'PERMISSION_DENIED',
} as const;

class FileSystemError extends Error {
    readonly kind: (typeof KIND)[keyof typeof KIND];

    constructor(kind: (typeof KIND)[keyof typeof KIND], message: string, options?: ErrorOptions) {
        super(message, options);
        this.kind = kind;
    }
}

function fileNotFoundError(fileName: string) {
    return new FileSystemError(KIND.NOT_FOUND, `File not found: ${fileName}`);
}

function permissionDeniedError(fileName: string) {
    return new FileSystemError(KIND.PERMISSION_DENIED, `Permission denied: ${fileName}`);
}
```

This gives callers a reliable `error.kind` to switch on without `instanceof`
chains, and keeps error messages consistent.

### Retry transient failures

When calling external services (HTTP APIs, databases, message queues), wrap
the call in retry logic if the failure is transient and the operation is
idempotent. Use exponential backoff with a cap. Do not retry non-idempotent
operations or errors that are clearly permanent (4xx client errors, validation
failures).

```ts
// Good — retry with backoff for a transient network call
const result = await retry(() => fetchFromApi(url), {
    retries: 3,
    backoff: 'exponential',
});

// Bad — no retry on a flaky network call that will fail intermittently
const result = await fetchFromApi(url);
```

Only add retries where failures are expected and recoverable. Do not blindly
retry everything — permanent errors should fail fast.

### Parallel execution of independent async work

When multiple async operations have no dependency on each other, run them in
parallel with `Promise.all` (or `Promise.allSettled` when partial failure is
acceptable). Sequential `await` of independent promises wastes time.

```ts
// Good — independent fetches run concurrently
const [users, orders, inventory] = await Promise.all([
    fetchUsers(),
    fetchOrders(),
    fetchInventory(),
]);

// Bad — sequential for no reason
const users = await fetchUsers();
const orders = await fetchOrders();
const inventory = await fetchInventory();
```

If one result feeds into the next call, sequential is correct. If not,
parallelize.

**Prefer library-level concurrency over JS-runtime concurrency.** When the
underlying system supports batching, pipelining, or multi-statement execution,
use that instead of firing multiple independent calls with `Promise.all`.
A single SQL query with multiple statements is cheaper than three queries
dispatched in parallel — fewer round-trips, less connection pressure, and
transactional guarantees come for free.

```ts
// Good — single round-trip, library handles it
const [users, orders] = await db.query(`
    SELECT * FROM users WHERE active = true;
    SELECT * FROM orders WHERE status = 'pending';
`);

// Acceptable but worse — two round-trips even if concurrent
const [users, orders] = await Promise.all([
    db.query('SELECT * FROM users WHERE active = true'),
    db.query("SELECT * FROM orders WHERE status = 'pending'"),
]);
```

Use `Promise.all` when the operations target *different* services or when the
library offers no batching primitive.

## Classes and services

### What is a Service?

A **Service** is a class that owns a cohesive piece of functionality. It groups
related private and public methods together because they share the same set of
dependencies. Three properties define a well-formed service:

1. **Dependency injection** — all collaborators are received via the
   constructor, making the dependency graph explicit and the service trivially
   testable (inject fakes/mocks, no monkey-patching).
2. **Immutability by default** — injected dependencies are `private readonly`
   and never reassigned. The service itself should be stateless when possible.
3. **Internal mutability** — when a service genuinely needs mutable state
   (caches, timers, counters), that state is `private` and never exposed for
   external modification. Outside code interacts only through the service's
   public method surface; it cannot reach in and mutate fields directly.

If code doesn't share dependencies with the rest of the service, it probably
belongs in a free function or a separate service — not bolted onto an existing
one.

### Dependency injection with a `Params` type

Service classes take their dependencies via constructor injection, using
**object destructuring of a single typed parameter**. Define a dedicated
`type <ClassName>Params = { … }` next to the class.

```ts
type UserServiceParams = {
    db: Pick<Database, 'query'>,
    logger: Logger,
    clock: Clock,
};

class UserService {

    private readonly db: UserServiceParams['db'];
    private readonly logger: Logger;
    private readonly clock: Clock;

    constructor({ db, logger, clock }: UserServiceParams) {
        this.db = db;
        this.logger = logger;
        this.clock = clock;
    }

    // …
}
```

### State-less, immutable dependencies — separate mutable state if any

Inject dependencies that are stateless and treat the injected references as
immutable. **Members holding dependencies should be `private readonly`.**

```ts
// Good
class UserService {

    private readonly db: Database;
    private readonly clock: Clock;

    constructor({ db, clock }: UserServiceParams) {
        this.db = db;
        this.clock = clock;
    }
}
```

When a class genuinely needs mutable state (caches, timers, counters,
in-flight bookkeeping), keep it **clearly separated** from the immutable
dependency block. Group all `private readonly` dependencies first, then the
mutable state below, ideally under a comment marker.

```ts
class TokenRefresher {

    // Dependencies — immutable.
    private readonly api: AuthApi;
    private readonly clock: Clock;

    // State — mutable.
    private currentToken: string | null = null;
    private refreshTimer: NodeJS.Timeout | null = null;

    constructor({ api, clock }: TokenRefresherParams) {
        this.api = api;
        this.clock = clock;
    }
}
```

If a "dependency" needs to be swapped or reconfigured at runtime, that's a
sign it should be modeled as a small mutable component the service depends
on — not as a directly-mutated field.

### No transitive service access — declare every dependency

Never reach through one injected service to call another. Each utility a
class uses must be declared explicitly in its `Params` type.

```ts
// Bad — transitive reach
class OrderService {
    constructor(private readonly app: AppContext) {}

    place(o: Order) {
        return this.app.payments.processor.charge(o);
    }
}

// Good — explicit dependency
type OrderServiceParams = {
    paymentProcessor: PaymentProcessor,
};

class OrderService {

    private readonly paymentProcessor: PaymentProcessor;

    constructor({ paymentProcessor }: OrderServiceParams) {
        this.paymentProcessor = paymentProcessor;
    }

    place(o: Order) {
        return this.paymentProcessor.charge(o);
    }
}
```

Chained accesses like `this.context.foo.bar.baz()` are always wrong. They
hide the real dependency graph, make tests require deep mock objects, and
turn the parent into a god object by proxy.

### No circular dependencies — use callbacks or events

Circular dependencies between services are always wrong. If service A depends
on service B and B also needs to call back into A, the design is tangled and
untestable.

Never pass `this` as a dependency to an object you create or own:

```ts
// Bad — circular: Job receives its parent, can call anything on it
class JobManager {
    run() {
        const job = new Job({ manager: this });
    }
}

// Good — pass only the specific callback the child needs
class JobManager {
    run() {
        const job = new Job({ onComplete: (result) => this.handleResult(result) });
    }
}
```

When a child object needs to communicate back to its parent, inject explicit
callbacks or use an event emitter — never hand over the entire parent
reference. This keeps the dependency graph acyclic, the coupling narrow, and
both sides independently testable.

### Lifecycle — provide a destructor when you allocate ephemeral resources

If a service starts timers, opens connections, subscribes to event emitters,
holds file/socket handles, or anything else that won't be reclaimed by GC,
expose an explicit teardown method (commonly `close()`, `dispose()`, or
`stop()`) and document that callers must invoke it.

```ts
class RemoteStateCache {

    private readonly api: RemoteApi;

    private refreshTimer: NodeJS.Timeout | null = null;
    private latest: State | null = null;

    constructor({ api }: RemoteStateCacheParams) {
        this.api = api;
    }

    start() {
        this.refreshTimer = setInterval(() => this.refresh(), 30_000);
    }

    close() {
        if (this.refreshTimer !== null) {
            clearTimeout(this.refreshTimer);
            this.refreshTimer = null;
        }
    }

    private async refresh() { … }
}
```

If a class has no mutable state and no external resources, it does not need
a destructor — don't invent one.

### Composition over inheritance — *always*

**Inheritance is the root of all evil.** Do not introduce `extends` between
your own classes to share code. Compose: hand the would-be parent in as a
dependency, or extract the shared logic into free functions or a helper
service.

```ts
// Bad — inheritance used for code reuse
class BaseService {
    protected logCall(name: string) { … }
}

class UserService extends BaseService { … }
class OrderService extends BaseService { … }

// Good — shared behavior is an injected utility
type CallLogger = { log(name: string): void };

class UserService {
    constructor(private readonly callLogger: CallLogger) {}
}

class OrderService {
    constructor(private readonly callLogger: CallLogger) {}
}
```

Hiding an implementation behind an `interface` (or a `type` shape) is good
and encouraged — that's polymorphism without an inheritance chain. Use it
freely.

When you have multiple shapes of data to handle, prefer **tagged unions**
over a class hierarchy:

```ts
// Good — tagged (discriminated) union
type Event =
    | { kind: 'login', userId: string }
    | { kind: 'purchase', userId: string, amount: number }
    | { kind: 'logout', userId: string };

function handle(event: Event) {
    switch (event.kind) {
        case 'login':    return onLogin(event);
        case 'purchase': return onPurchase(event);
        case 'logout':   return onLogout(event);
    }
}

// Bad — class hierarchy for data
abstract class Event { abstract handle(): void; }
class LoginEvent extends Event { … }
class PurchaseEvent extends Event { … }
class LogoutEvent extends Event { … }
```

The only places `extends` is acceptable:

- Extending framework-provided classes that require it (e.g., `Error`,
  `EventEmitter` when the API genuinely needs it).
- A class `implements` an interface — that is *not* inheritance, use it.

### Minimal dependencies

Depend on the smallest surface you actually use. Prefer `Pick<Config, 'a' | 'b'>`
over passing the whole config object. This keeps services testable and makes
their real coupling visible.

```ts
// Good
type RateLimiterParams = {
    config: Pick<AppConfig, 'rateLimit' | 'rateWindowMs'>,
};

// Bad — pulls in the whole config for two fields
type RateLimiterParams = {
    config: AppConfig,
};
```

### Visibility

- **Private** methods/properties: use the `private` keyword. No `_` prefix,
  no other naming convention.
- **Public** methods/properties: no visibility specifier in classes. Don't
  write `public foo()`; just `foo()`.

```ts
// Good
class Foo {

    private cache: Map<string, Bar>;

    handle(req: Request) { … }

    private parse(raw: string) { … }
}

// Bad
class Foo {

    public handle(req: Request) { … }

    private _parse(raw: string) { … }
}
```

## Testability

Code is written to be tested. Two consequences:

- **Extract free functions liberally.** Pure mapping/transformation functions,
  simple wrappers over library code, reusable utilities, and large self-contained
  code blocks should all live outside the class as free functions in the same
  module when doing so improves readability. The class delegates to them. This
  makes the logic trivial to unit-test without instantiating the class.

  ```ts
  // Good — pure function exported, class delegates
  export function toUserDTO(row: UserRow): UserDTO { … }

  // Good — library wrapper extracted for readability
  function parseConfig(raw: string): Config {
      return yaml.parse(raw, { strict: true, merge: true });
  }

  class UserService {
      get(id: string) {
          const row = this.db.find(id);

          return toUserDTO(row);
      }
  }
  ```

- Constructor DI (see above) means tests inject fakes/mocks without monkey
  patching. If something is hard to test, the structure is wrong — fix the
  structure, don't add test scaffolding around it.

## Types

- **Prefer `type` over `interface`.** Only use `interface` when you genuinely
  intend it to be `implements`-ed by one or more classes.
- Trailing commas everywhere — in object/array literals, type members,
  function parameter lists, tuple types — **except** for single-line
  destructuring patterns (`const { a, b } = x;`).

```ts
// Good
type Point = {
    x: number,
    y: number,
};

interface Repository {
    find(id: string): Promise<Entity>;
    save(e: Entity): Promise<void>;
}

class MongoRepository implements Repository { … }

const fn = (
    a: number,
    b: number,
) => a + b;

const { name, age } = user;   // no trailing comma on a single-line destructure

// Bad
interface Point {           // no class implements this — should be `type`
    x: number;
    y: number;
}

type FnArgs = (
    a: number,
    b: number              // missing trailing comma
) => number;
```

## Constants and enumerations

### Module-scope constants use SCREAMING_CASE

Constants declared at module scope are always `SCREAMING_CASE`. They may or
may not be exported.

```ts
const MAX_RETRIES = 3;
const DEFAULT_TIMEOUT_MS = 30_000;

export const API_VERSION = 'v2';
```

### No TypeScript `enum` — use `as const` objects

TypeScript `enum` must never be used. They produce surprising runtime
artifacts and don't compose well with the type system. Instead, use a plain
`const` object with `as const`:

```ts
// Good — grouped constants
const HTTP_METHOD = {
    GET: 'GET',
    POST: 'POST',
    PUT: 'PUT',
    DELETE: 'DELETE',
} as const;

type HttpMethod = (typeof HTTP_METHOD)[keyof typeof HTTP_METHOD];

// Bad — TS enum
enum HttpMethod {
    GET = 'GET',
    POST = 'POST',
}
```

This pattern gives you autocompletion, exhaustiveness checking via the derived
union type, and zero runtime overhead beyond a plain object.

## Quick checklist before finishing a TypeScript edit

1. All `if`/`else`/loop bodies are braced.
2. Blank line after `if`/`else` blocks (except mid-chain).
3. Blank line before every `return` that isn't the only statement.
4. Early returns instead of nested `if`/`else`.
5. `function` declarations except for `.map`/`.filter`/`.reduce`/`this` cases.
6. Service classes use `{ … }: <Name>Params` constructor with a sibling
   `type <Name>Params`.
7. Dependency members are `private readonly`; any mutable state is grouped
   separately and clearly marked.
8. No transitive service access (`this.x.y.z()`) — every utility is its own
   declared dependency.
9. No circular dependencies — use callbacks or events, never pass `this` to
   owned objects.
10. Classes that allocate timers/connections/handles expose an explicit
    `close()` / `dispose()` / `stop()` teardown.
11. No `extends` between your own classes — compose instead. Multi-shape
    data uses tagged unions, not class hierarchies.
12. Dependencies narrowed with `Pick<>` where possible.
13. Pure transforms live as free functions outside classes.
14. `type` over `interface` unless a class implements it.
15. Trailing commas everywhere except single-line destructuring.
16. No `try`/`catch` unless the catch actually handles the error.
