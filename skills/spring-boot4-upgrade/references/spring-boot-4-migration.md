# Spring Boot 4 migration checklist

Use this reference for every migration. Verify the selected maintenance release against the current official documentation before applying exact dependency versions.

## Table of contents

- [Authoritative baseline](#authoritative-baseline)
- [Build and platform](#build-and-platform)
- [Modularization](#modularization)
- [Jackson](#jackson)
- [Security](#security)
- [Testing](#testing)
- [Runtime changes](#runtime-changes)
- [Verification](#verification)

## Authoritative baseline

Start from the latest applicable Spring Boot 3.5.x release, eliminate deprecated API use, and review the official Spring Boot 4 migration guide. Spring Boot 4 requires Java 17 or later, is based on Spring Framework 7 and Jakarta EE 11, and uses a Servlet 6.1 baseline.

Primary sources:

- [Spring Boot 4.0 Migration Guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-4.0-Migration-Guide)
- [Spring Boot reference documentation](https://docs.spring.io/spring-boot/4.0/)
- [Spring Security migration documentation](https://docs.spring.io/spring-security/reference/migration/)

Also review release notes for Spring Data, Security, Batch, Integration, AMQP, Kafka, Session, and other Spring portfolio projects used by the application.

## Build and platform

- Use the Spring Boot parent or BOM for the selected release.
- Review all explicitly versioned dependencies and plugins; remove overrides already managed by Boot unless they solve a documented compatibility need.
- Update compiler release, CI toolchains, test JVMs, runtime images, and local developer setup together.
- Use the Spring Boot properties migrator temporarily to identify renamed properties, then remove it after migration.
- Compare the effective POM or Gradle resolution result before and after the upgrade.

## Modularization

Spring Boot 4 splits broad modules into focused technology modules and starters. Do not infer the complete replacement set from a single missing class. Use the official migration guide's starter and module tables.

Common examples include:

| Boot 3 dependency | Boot 4 direction |
|---|---|
| `spring-boot-starter-web` | Prefer `spring-boot-starter-webmvc` for servlet MVC |
| Broad implicit client support | Add the focused REST client or WebClient starter when used |
| `spring-boot-starter-test` | Add focused test starters required by the selected technologies |
| `spring-boot-starter-batch` with persisted metadata | Use `spring-boot-starter-batch-jdbc` |

`spring-boot-starter-classic` and `spring-boot-starter-test-classic` can temporarily restore a broader classpath during migration. Treat them as a bridge, not the final dependency design.

## Jackson

Jackson 3 is Spring Boot 4's preferred JSON stack and uses `tools.jackson` packages for most modules. The annotations module remains under `com.fasterxml.jackson.annotation`. Boot 4 provides the deprecated `spring-boot-jackson2` compatibility module for a time-boxed transition.

Do not assume that registering a Jackson 2 `ObjectMapper` replaces Boot's Jackson 3 `JsonMapper`. Decide which stack owns HTTP serialization and test both framework-managed and directly injected mappers. See [jackson-migration.md](jackson-migration.md).

## Security

Spring Security 7 removes `.and()` from the `HttpSecurity` DSL and removes `authorizeRequests` in favor of `authorizeHttpRequests`. Migrate to lambda configuration while preserving the application's existing authorization rules.

CSRF protection is not a new Boot 4 behavior. Do not disable it merely to make tests pass. Decide based on the application's client model and add tests for allowed and rejected requests.

Access-decision APIs may require the separate `spring-security-access` module or migration to `AuthorizationManager`, depending on the use case. Verify against the selected Security release.

## Testing

- Replace Boot's removed `@MockBean` and `@SpyBean` with Spring Framework's `@MockitoBean` and `@MockitoSpyBean`.
- Add `@AutoConfigureMockMvc` when a `@SpringBootTest` needs MockMvc.
- Add `@AutoConfigureTestRestTemplate` and the required focused dependencies when retaining `TestRestTemplate`, or migrate to `RestTestClient` with its auto-configuration.
- Use Mockito's `MockitoExtension` for plain Mockito `@Mock` and `@Captor` fields when the removed listener previously initialized them.
- Account for the restriction that `@MockitoBean` and `@MockitoSpyBean` are not used as fields inside `@Configuration` classes; use type-level declarations or a composed annotation for shared mocks.

## Runtime changes

- Undertow support is removed because Boot 4 requires Servlet 6.1. Select a supported servlet container or a reactive stack.
- Spring Batch's regular starter can run without a database. Use the JDBC starter when job metadata must remain persistent.
- Liveness and readiness probe exposure changed; verify the deployed health groups and security rules.
- Custom message-converter registration and package locations changed with modularization. Prefer the new client and server converter customizers described by the official guide.
- Custom starters should generally publish distinct Boot 3 and Boot 4 artifacts rather than attempting one binary for both generations.

## Verification

Verify at four levels:

1. Compile and unit tests for affected modules.
2. Full build with integration tests and dependency convergence checks.
3. Runtime startup of every deployable application plus representative API, security, serialization, database, and observability checks.
4. Container or platform smoke test using the actual image, environment, probes, and rollout mechanism.

Record commands and outcomes. A build-only result is incomplete.
