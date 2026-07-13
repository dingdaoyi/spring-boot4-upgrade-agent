# OpenAPI library compatibility

Use this reference when `/v3/api-docs`, Swagger UI, Knife4j, or another OpenAPI integration fails after moving to Spring Boot 4 or Spring Framework 7.

## Diagnose the library family

Inspect the resolved versions of:

- springdoc modules;
- Swagger Core models, annotations, and Jakarta variants;
- UI or documentation extensions such as Knife4j;
- Spring Framework web modules;
- Jackson 2 and Jackson 3 modules.

Maven example:

```bash
./mvnw -pl <application-module> dependency:tree -Dverbose \
  -Dincludes=org.springdoc,io.swagger.core.v3,com.github.xiaoymin
```

Gradle example:

```bash
./gradlew <module>:dependencies --configuration runtimeClasspath
```

## Interpret common failures

| Symptom | Investigation |
|---|---|
| `NoSuchMethodError` involving `ControllerAdviceBean` | A springdoc generation compiled for an older Spring Framework may be present |
| `NoSuchMethodError` involving `Schema` | Mixed Swagger annotation or model artifacts may expose the same class from incompatible versions |
| Missing springdoc configuration method | A UI extension may call an API removed by the resolved springdoc release |
| Jackson mapper or module error | The OpenAPI stack may not support the application's selected Jackson major version |

Identify the caller from the stack trace before changing dependencies. Confirm the missing method with `javap` against both the caller's expected release and the runtime JAR.

## Fix strategy

1. Select a springdoc release that explicitly supports the chosen Spring Boot and Spring Framework release.
2. Select an extension release that explicitly supports that springdoc generation.
3. Exclude stale transitive springdoc or Swagger artifacts.
4. Use one coherent Jakarta Swagger family; avoid simultaneous artifacts that publish the same package and class names.
5. Prefer removing or temporarily disabling the optional UI extension over shipping a broad no-op subclass that bypasses unknown behavior.
6. If no compatible release exists, document the limitation and expose the base OpenAPI endpoint without the extension when acceptable.

Do not copy an application-specific compatibility bean from an old incident without verifying the current constructors, conditions, and lost behavior.

## Verify

After startup, verify without embedding credentials in commands or documentation:

```bash
curl --fail-with-body http://localhost:<port>/v3/api-docs
curl --fail-with-body http://localhost:<port>/v3/api-docs/swagger-config
```

When authentication is required, obtain credentials through the project's approved secret mechanism. Also test grouped documents, UI loading, schema generation for representative models, and authorization of documentation endpoints.
