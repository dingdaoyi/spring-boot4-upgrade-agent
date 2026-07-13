# Jackson 2 to Jackson 3 migration

Use this reference when the project imports Jackson APIs, injects an `ObjectMapper`, defines modules or serializers, customizes HTTP converters, or depends on a library that still requires Jackson 2.

## Table of contents

- [Choose one primary path](#choose-one-primary-path)
- [Native Jackson 3 path](#native-jackson-3-path)
- [Temporary Jackson 2 bridge](#temporary-jackson-2-bridge)
- [Mixed-stack rules](#mixed-stack-rules)
- [Verification](#verification)

## Choose one primary path

Prefer migrating application-owned code to Jackson 3. Use Boot's Jackson 2 compatibility module only when an upstream library blocks the migration, and record the condition for removing the bridge.

Inventory before editing:

```bash
rg -n 'com\.fasterxml\.jackson|tools\.jackson|ObjectMapper|JsonMapper|JsonComponent|JsonMixin' \
  --glob '*.java' --glob '*.kt' .
```

Classify each use as:

- HTTP serialization managed by Spring MVC or WebFlux;
- an application-injected mapper;
- a library-owned mapper;
- a format-specific mapper such as XML;
- a custom module, serializer, deserializer, mixin, or annotation.

## Native Jackson 3 path

Spring Boot 4 prefers Jackson 3. Most packages move from `com.fasterxml.jackson` to `tools.jackson`; Jackson annotations remain under `com.fasterxml.jackson.annotation`.

Review these migration points against the selected Boot release:

| Jackson 2 / Boot 3 | Jackson 3 / Boot 4 direction |
|---|---|
| `com.fasterxml.jackson.databind.ObjectMapper` | `tools.jackson.databind.ObjectMapper` or JSON-specific `JsonMapper` |
| `Jackson2ObjectMapperBuilderCustomizer` | `JsonMapperBuilderCustomizer` |
| `@JsonComponent` | `@JacksonComponent` |
| `@JsonMixin` | `@JacksonMixin` |
| `spring.jackson.read.*` and `spring.jackson.write.*` | JSON-specific properties under `spring.jackson.json.*` |

Boot 4 auto-configures format-specific mappers. Defining a generic `ObjectMapper` does not necessarily replace the auto-configured JSON or XML mapper; define or customize the specific mapper type required by the application.

Use `spring.jackson.use-jackson2-defaults=true` only when the Boot 4 documentation for the selected release supports it and compatibility with Boot 3 defaults is deliberately required.

## Temporary Jackson 2 bridge

Spring Boot 4 provides a deprecated Jackson 2 module as a stop-gap:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-jackson2</artifactId>
</dependency>
```

```kotlin
implementation("org.springframework.boot:spring-boot-jackson2")
```

Jackson 2 compatibility properties live under `spring.jackson2`. Confirm the exact property names in the selected Boot reference documentation.

Do not introduce a bean named `objectMapper` merely to satisfy a failing injection point. First identify whether the consumer expects Jackson 2 or 3, whether injection is by name or type, and whether that mapper is supposed to own HTTP serialization.

## Mixed-stack rules

- Keep Jackson 2 and Jackson 3 types explicit in imports and bean names.
- Never pass a Jackson 2 module, serializer, or node type to a Jackson 3 mapper, or the reverse.
- Customize Boot's HTTP mapper through the Boot 4 customization API instead of replacing converters opportunistically.
- Align Kotlin, Java time, parameter-names, and datatype modules with the mapper major version.
- Test annotations and custom serializers independently; annotations retain the old package while databind types move.
- Avoid global Long-to-String policies unless the public API contract requires them. If required, test primitive, boxed, collection, and nested values through the actual HTTP path.

## Verification

Test all paths that may use different mappers:

1. Deserialize a representative request body.
2. Serialize a representative response body.
3. Invoke code that directly injects or constructs a mapper.
4. Exercise custom modules, mixins, naming strategies, dates, enums, unknown properties, and polymorphic types.
5. Verify management endpoints or messaging serializers separately when they use isolated mappers.
6. Inspect the dependency tree for an unintended mix of Jackson 2 and 3 databind modules.

Primary sources:

- [Spring Boot 4 migration guide: Upgrading Jackson](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-4.0-Migration-Guide#upgrading-jackson)
- [Spring Boot JSON reference](https://docs.spring.io/spring-boot/4.0/reference/features/json.html)
