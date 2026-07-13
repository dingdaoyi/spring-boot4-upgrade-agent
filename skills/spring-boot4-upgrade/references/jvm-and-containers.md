# JVM and container verification

Use this reference when the local build works but the packaged application or container fails, or when changing the Java release as part of the Spring Boot upgrade.

## Table of contents

- [Align every Java runtime](#align-every-java-runtime)
- [Choose the image deliberately](#choose-the-image-deliberately)
- [Add JVM flags only with evidence](#add-jvm-flags-only-with-evidence)
- [Diagnose attach and instrumentation failures](#diagnose-attach-and-instrumentation-failures)
- [Verify the final image](#verify-the-final-image)

## Align every Java runtime

Capture all four versions:

```bash
java -version
./mvnw -version
./gradlew --version
docker run --rm <image> java -version
```

The compiler release, Maven or Gradle daemon, test forks, build image, and runtime image can differ. Update toolchains and CI configuration explicitly rather than relying on the developer shell.

## Choose the image deliberately

- Use a JRE image when the application needs only runtime modules.
- Use a JDK image when runtime instrumentation, attach, compilation, diagnostics, or another feature requires JDK modules and tools.
- Pin an immutable image digest for reproducible production releases, or use an explicit patch tag with a controlled update process.
- Match CPU architecture and libc expectations for native libraries.
- Run as a non-root user and verify writable directories, trust stores, time zone data, fonts, and native dependencies.

Do not claim that every service must use a JRE or every service must use a JDK. The correct choice follows from the actual runtime features.

## Add JVM flags only with evidence

Flags such as these are library- and JDK-specific:

```text
--add-opens=<module>/<package>=ALL-UNNAMED
--sun-misc-unsafe-memory-access=allow
-XX:+UnlockExperimentalVMOptions
-XX:+UseCompactObjectHeaders
```

Before adding one:

1. Capture the exception and the library that triggers it.
2. Verify the flag exists in the selected Java release.
3. Check the library's current release notes for a compatible version that removes the need.
4. Scope the flag to the affected service and document its removal condition.
5. Run startup and workload tests with the final container command.

Module opens and unsafe-memory allowances weaken encapsulation. Experimental VM features can change performance and support characteristics. They are not generic Spring Boot 4 requirements.

## Diagnose attach and instrumentation failures

If a debug agent, profiler, Byte Buddy integration, or other instrumentation cannot attach:

- confirm whether the runtime image contains the required attach module;
- verify container security settings, process permissions, and temporary-directory access;
- decide whether the feature belongs in production;
- prefer a compatible startup agent or a JDK runtime when instrumentation is required;
- disable an optional development agent only after confirming that it is not required by production behavior.

Do not globally inject a property through an `EnvironmentPostProcessor` merely to suppress a startup error across unrelated services.

## Verify the final image

Inspect and run the exact built image:

```bash
docker inspect <image>
docker run --rm <image> java -XshowSettings:vm -version
docker run --rm -p 8080:8080 <image>
```

Verify:

- the intended Java vendor, version, modules, architecture, entry point, and flags;
- startup as the configured user;
- memory and CPU behavior under the deployment limits;
- certificate trust and outbound TLS;
- graceful shutdown and signal handling;
- health endpoints and temporary-directory writes.

Treat a container-only failure as an environment delta until evidence shows otherwise.
