# Virtual threads across Java releases

Use this reference when `spring.threads.virtual.enabled=true` is present, when the upgrade proposes enabling virtual threads, or when throughput changes after a Java upgrade.

## Account for the Java release

Java 21 introduced virtual threads. On Java 21 through 23, blocking while holding a `synchronized` monitor can pin a virtual thread to its carrier. Java 24 delivered [JEP 491](https://openjdk.org/jeps/491), which allows virtual threads blocked in `synchronized` methods and statements to unmount in nearly all cases.

Therefore:

- on Java 21-23, investigate monitor pinning on blocking paths;
- on Java 24 and later, do not mechanically replace every `synchronized` block with `ReentrantLock` for pinning reasons;
- on all releases, measure contention, blocking, native calls, and downstream resource limits.

Remaining pinning can involve native or foreign-function calls that call back into blocking Java code. Use diagnostics supported by the selected JDK, including JFR virtual-thread events where available.

## Review workload suitability

Virtual threads help thread-per-request workloads that spend significant time waiting on blocking I/O. They do not make CPU-bound work faster and do not remove limits imposed by:

- database connection pools;
- HTTP client connection pools;
- rate limits and downstream concurrency;
- memory held per request;
- synchronized state or lock contention;
- native libraries and blocking foreign calls.

Run a representative load test and monitor latency, carrier utilization, connection pools, allocation, and downstream saturation.

## Treat ThreadLocal accurately

Each virtual thread has its own `ThreadLocal` state; carrier-thread reuse does not make request values leak between virtual threads. The practical risks are the cost of very large numbers of thread-local values, inheritance semantics, and context that outlives its intended scope.

- Remove values in long-lived platform-thread pools when application code owns the lifecycle.
- Avoid using `InheritableThreadLocal` as a blanket fix for virtual threads.
- Preserve Spring Security's supported context strategy unless the application's propagation model requires a documented change.
- Consider scoped values on Java releases where they are supported when immutable, bounded-lifetime context is a better fit.

## Migration checklist

1. Confirm the Java release in the deployed image.
2. Identify blocking request paths and pool limits.
3. Enable virtual threads in a non-production environment.
4. Run representative concurrency tests.
5. Inspect JFR and application metrics for pinning, contention, allocation, and saturation.
6. Change synchronization only when diagnostics show a problem or the locking design is independently unsafe.
7. Verify cancellation, timeouts, logging context, security context, and observability propagation.

Do not carry Java 21 pinning advice unchanged into Java 24 or 25 deployments.
