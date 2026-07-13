---
name: spring-boot4-upgrade
description: Audit, plan, execute, diagnose, and verify Spring Boot 3.5 to 4.x upgrades for Maven or Gradle projects. Use when migrating to Spring Boot 4 or Spring Framework 7, adopting a compatible Java release, resolving compile-time or startup failures after a Spring dependency upgrade, aligning modular starters and third-party dependencies, migrating Jackson 2 to 3 or Spring Security 6 to 7, updating Spring Boot tests, or investigating an upgrade that builds successfully but fails at runtime.
---

# Spring Boot 4 Upgrade

Treat an upgrade as a staged runtime migration, not a version-number edit. A successful compile or package is necessary but does not prove that auto-configuration, service-provider loading, serialization, database migration, security, or container startup works.

Resolve `<skill-root>` in commands as the directory that contains this `SKILL.md` file.

## Establish the upgrade contract

Before editing, determine and record:

- the current Spring Boot patch version and the requested target 4.x maintenance release;
- the Java version used by developers, CI, tests, and the runtime image;
- the build tool, wrapper, module graph, application entry modules, and packaging type;
- the database engines and versions, migration tool, servlet or reactive stack, and deployment target;
- the baseline build, test, startup, health, and critical API behavior.

Do not silently select a target minor release. If the user did not choose one, inspect repository constraints and ask only when different choices materially change the work. When current upstream information is available, verify it against official release notes and documentation.

Read [references/spring-boot-4-migration.md](references/spring-boot-4-migration.md) before changing the project. Read the other references only when their trigger matches the repository or observed failure.

## Apply safety rules

- Preserve unrelated user changes and inspect the working tree before editing.
- Prefer the project's Maven or Gradle wrapper.
- Change one compatibility layer at a time and keep each verification result attributable.
- Use the Spring Boot BOM or parent as the authoritative version set. Remove unnecessary overrides before adding new ones.
- Verify third-party compatibility from its upstream release notes, published metadata, or resolved bytecode. Do not trust a stale version table.
- Do not disable CSRF, TLS, database migrations, Spring Cloud compatibility checks, or other safety controls as a generic fix. Diagnose the mismatch and document any temporary exception.
- Do not add JVM module-opening or unsafe-memory flags without a matching runtime failure and a documented library requirement.
- Do not commit, push, publish, or deploy unless the user explicitly requests it.

## Execute the migration

### 1. Capture a clean baseline

1. Upgrade the application to the latest applicable Spring Boot 3.5.x maintenance release.
2. Remove or replace Spring Boot 3.x deprecations while still on 3.5.x.
3. Run the existing build and tests and start each deployable application.
4. Record important endpoints, serialization output, database migration state, and container health.
5. Run the bundled advisory scan:

```bash
bash <skill-root>/scripts/upgrade-audit.sh <project-root>
```

Treat every scan result as evidence to inspect, not as an automatic edit instruction.

### 2. Align the build and dependency graph

1. Update the Spring Boot parent or imported BOM to the selected 4.x maintenance release.
2. Set a Java release supported by that Boot version and by the deployment platform.
3. Replace renamed or removed starters and add focused main or test starters required by Boot 4 modularization.
4. Use classic starters only as a temporary diagnostic bridge; remove them before declaring the migration complete.
5. Compare resolved dependencies before and after the change:

```bash
./mvnw dependency:tree
./gradlew dependencies
```

6. Remove direct versions that override Spring Boot management unless the override is intentional, documented, and tested.
7. Verify every non-Boot starter against its upstream Boot 4 or Framework 7 support statement.

For binary linkage failures, read [references/dependency-conflicts.md](references/dependency-conflicts.md). For custom JSqlParser integrations, also read [references/jsqlparser-5x-api-migration.md](references/jsqlparser-5x-api-migration.md).

### 3. Migrate source and configuration

- Update relocated Spring Boot imports and configuration properties reported by the compiler and properties migrator.
- Choose a deliberate Jackson strategy: migrate application code to Jackson 3, or use the deprecated Jackson 2 compatibility module as a time-boxed bridge. Read [references/jackson-migration.md](references/jackson-migration.md).
- Migrate Spring Security configuration to the Security 7 lambda DSL and preserve explicit authorization and CSRF behavior.
- Replace removed Boot test annotations and add focused test auto-configuration and dependencies.
- Recheck custom auto-configuration imports, `EnvironmentPostProcessor` registrations, service-provider files, and native-image hints.
- Keep database changes separate from framework changes where possible; never bypass migration failures without an approved operational alternative.

### 4. Verify runtime and deployment behavior

Run verification from the narrowest affected module to the full reactor or multi-project build:

```bash
./mvnw -pl <application-module> -am test
./mvnw -pl <application-module> -am package
./mvnw -pl <application-module> spring-boot:run
```

Use equivalent Gradle tasks when the project uses Gradle. Then verify:

- the packaged artifact starts with the same Java runtime and flags used in deployment;
- health, readiness, and liveness behavior is correct;
- representative JSON input and output remains compatible;
- authentication, authorization, CSRF, CORS, and error mapping behave as intended;
- database migrations run exactly once and application data access works;
- observability, OpenAPI generation, scheduled jobs, messaging, and batch persistence work when present;
- the container image starts as its configured user with its actual JRE or JDK;
- the deployment reaches a stable rollout without rising restart counts.

Read [references/jvm-and-containers.md](references/jvm-and-containers.md), [references/virtual-threads.md](references/virtual-threads.md), [references/postgresql-ssl-troubleshooting.md](references/postgresql-ssl-troubleshooting.md), or [references/kubernetes-startup-triage.md](references/kubernetes-startup-triage.md) only when relevant.

## Diagnose failures

1. Capture the first meaningful `Caused by` chain, not only the final wrapper exception.
2. Classify the failure as source compatibility, missing class, binary linkage, bean wiring, configuration binding, infrastructure, or behavior regression.
3. Inspect the resolved dependency path for every class named in `ClassNotFoundException`, `NoClassDefFoundError`, or `NoSuchMethodError`.
4. Compare the caller's compiled API with the runtime class using `dependency:tree`, Gradle dependency insight, `jar tf`, and `javap`.
5. Make the smallest change that restores a coherent dependency graph or documented API.
6. Re-run the narrow failing check, then the full runtime verification.

Use [references/openapi-compatibility.md](references/openapi-compatibility.md) for springdoc, Swagger, or Knife4j linkage errors.

## Complete the upgrade

Report:

- the selected Boot and Java versions;
- build, source, configuration, test, and deployment changes;
- exact verification commands and their outcomes;
- temporary bridges or version overrides that remain;
- skipped checks, residual risks, and recommended follow-up work.

Do not claim completion while an application entry point, migration path, or required deployment smoke test remains unverified.

## Bundled resources

| Resource | Read or run when |
|---|---|
| `references/spring-boot-4-migration.md` | Always; official major-version change checklist |
| `references/dependency-conflicts.md` | Dependency convergence or binary linkage fails |
| `references/jackson-migration.md` | Jackson 2 imports, mappers, modules, or custom serializers exist |
| `references/jsqlparser-5x-api-migration.md` | The project directly uses JSqlParser APIs |
| `references/openapi-compatibility.md` | OpenAPI generation or UI fails after the upgrade |
| `references/jvm-and-containers.md` | Java runtime, image, attach, module, or memory-access issues occur |
| `references/virtual-threads.md` | Virtual threads are enabled or proposed |
| `references/postgresql-ssl-troubleshooting.md` | PostgreSQL TLS or authentication ends with EOF or handshake errors |
| `references/kubernetes-startup-triage.md` | Pods restart or fail readiness after deployment |
| `scripts/upgrade-audit.sh` | Run the preflight repository scan |
| `scripts/scan-class-references.sh` | Find JARs that reference a removed binary class name |
| `scripts/flyway-mysql-version-matrix.sh` | Inspect explicitly selected Flyway versions; requires network access |
