# Dependency and binary compatibility diagnosis

Use this reference when compilation succeeds but startup fails with a missing class or method, or when two modules resolve different versions of the same library.

## Table of contents

- [Classify the failure](#classify-the-failure)
- [Trace the resolved dependency](#trace-the-resolved-dependency)
- [Inspect the binary contract](#inspect-the-binary-contract)
- [Resolve the graph](#resolve-the-graph)
- [Frequent upgrade surfaces](#frequent-upgrade-surfaces)

## Classify the failure

| Failure | Likely meaning |
|---|---|
| `ClassNotFoundException` | A runtime path tried to load a class that is absent |
| `NoClassDefFoundError` | A class existed at compile time or during initialization but is absent or failed to initialize at runtime |
| `NoSuchMethodError` | The caller was compiled against a different binary API than the runtime class provides |
| `AbstractMethodError` | An implementation no longer satisfies the runtime interface contract |
| `ServiceConfigurationError` | A service-provider declaration references an absent or incompatible provider |

Capture the first meaningful cause and identify both the caller and the missing target. Avoid fixing only the top-level Spring bean exception.

## Trace the resolved dependency

For Maven:

```bash
./mvnw -pl <application-module> dependency:tree -Dverbose
./mvnw -pl <application-module> dependency:tree -Dincludes=<groupId>:<artifactId>
./mvnw help:effective-pom
```

For Gradle:

```bash
./gradlew <module>:dependencies --configuration runtimeClasspath
./gradlew <module>:dependencyInsight \
  --configuration runtimeClasspath \
  --dependency <artifact-or-module>
```

Check parent POMs, convention plugins, dependency constraints, imported BOMs, test fixtures, and submodules. A declaration with `provided`, `runtime`, or test scope can still alter the classpath used by a particular launch or test task.

## Inspect the binary contract

Locate the runtime JAR and inspect it directly:

```bash
jar tf path/to/library.jar | grep 'TargetClass.class'
javap -classpath path/to/library.jar -p fully.qualified.TargetClass
```

To find local Maven artifacts whose bytecode references a removed binary class name:

```bash
bash <skill-root>/scripts/scan-class-references.sh \
  net/example/RemovedType ~/.m2/repository
```

Treat string scanning as a fast candidate finder. Confirm important hits with `javap -c -p` or a bytecode analysis tool.

Also inspect service providers and auto-configuration metadata:

```bash
unzip -l path/to/library.jar | grep -E 'META-INF/services|AutoConfiguration.imports|spring.factories'
unzip -p path/to/library.jar META-INF/services/<service-interface>
```

## Resolve the graph

Prefer fixes in this order:

1. Upgrade or replace the incompatible library with a release that explicitly supports the selected Spring Boot and Spring Framework versions.
2. Remove an unnecessary direct version and let Spring Boot dependency management choose a coherent version.
3. Exclude a stale transitive dependency and add the compatible replacement explicitly.
4. Migrate custom integration code to the new public API.
5. Isolate a legacy integration behind a separate process or postpone that feature when no compatible release exists.

Do not copy an arbitrary version number from an old incident. Verify the current upstream release notes and the selected Boot BOM.

When multiple BOMs manage the same artifact, inspect the effective model and resolved tree. Keep ownership clear and document any override; declaration order alone is not sufficient evidence that the final graph is correct.

## Frequent upgrade surfaces

### JSqlParser consumers

Spring Data or persistence extensions may move to a newer JSqlParser major release while custom interceptors or pagination libraries still call removed APIs. Inspect all direct JSqlParser imports and bytecode consumers. Read [jsqlparser-5x-api-migration.md](jsqlparser-5x-api-migration.md).

### HTTP clients and TLS classes

A `NoClassDefFoundError` for an Apache HttpClient or Reactor Netty TLS class usually means a direct version pin conflicts with Spring Boot's managed client stack. Remove the pin or align the entire client family; do not add a single JAR until the resolved tree is coherent.

### Hibernate extensions

Hibernate major upgrades remove or relocate SPI types. Service-loaded type contributors can fail only at startup. Verify that the extension targets the Hibernate version managed by the selected Boot release.

### Metrics and observability

Micrometer registries, Prometheus libraries, and tracing bridges must be upgraded as a family. A method-linkage error across those artifacts is evidence of mixed release trains.

### OpenAPI libraries

springdoc, Swagger Core, UI extensions, and framework adapters share binary APIs. Align the full family and read [openapi-compatibility.md](openapi-compatibility.md).

### Database migration tools

Database support can depend on Flyway or Liquibase edition, module split, database version, and the version managed by Boot. Verify support from the selected tool release. Disabling migrations is an operational decision, not a default compatibility fix.
