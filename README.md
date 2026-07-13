# Spring Boot 4 Upgrade

An evidence-first agent skill for upgrading Spring Boot 3.5 applications to Spring Boot 4.x. It guides dependency alignment, source migration, runtime diagnosis, and release verification without assuming that a successful compile proves the upgrade is complete.

## What it covers

- Spring Boot 4 modular starters and package changes
- Jackson 3 migration with an explicit Jackson 2 bridge strategy
- Spring Security 7 and Spring Boot test migration
- Dependency and bytecode conflict diagnosis
- Database migration, container, JVM, virtual-thread, and Kubernetes checks
- Runtime smoke tests and evidence-based completion criteria

The skill avoids hard-coding a supposedly universal set of third-party versions. It tells the agent to verify the selected Spring Boot maintenance release, upstream compatibility information, and the application's resolved dependency graph.

## Repository layout

```text
.
├── .claude-plugin/                 # Claude Code plugin and marketplace metadata
├── skills/
│   └── spring-boot4-upgrade/       # Portable skill package
│       ├── SKILL.md
│       ├── agents/openai.yaml
│       ├── references/
│       └── scripts/
├── LICENSE
└── README.md
```

## Install

### Codex

```bash
git clone https://github.com/dingdaoyi/spring-boot4-upgrade-agent.git
mkdir -p ~/.codex/skills
cp -R spring-boot4-upgrade-agent/skills/spring-boot4-upgrade ~/.codex/skills/
```

Then invoke it with a request such as:

```text
Use $spring-boot4-upgrade to audit this Maven project and plan a Spring Boot 4 migration.
```

### Claude Code

Add this repository as a marketplace and install the plugin:

```text
/plugin marketplace add dingdaoyi/spring-boot4-upgrade-agent
/plugin install spring-boot4-upgrade@spring-boot4-upgrade
```

For local development, run `claude --plugin-dir .` from the repository root. The fully qualified skill command is `/spring-boot4-upgrade:spring-boot4-upgrade`.

## Run the preflight audit directly

```bash
bash skills/spring-boot4-upgrade/scripts/upgrade-audit.sh /path/to/project
```

The audit is advisory by default. Add `--strict` when warnings should produce a non-zero exit code.

## Design principles

- Upgrade to the latest Spring Boot 3.5 maintenance release before crossing the major-version boundary.
- Treat the official migration guide and the selected release's dependency management as the source of truth.
- Capture a working baseline, migrate in stages, and verify the packaged application at runtime.
- Do not disable TLS, CSRF, database migrations, or compatibility checks as a generic workaround.
- Do not push, publish, or deploy unless the user explicitly asks for it.

## Primary references

- [Spring Boot 4.0 Migration Guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-4.0-Migration-Guide)
- [Spring Boot 4 reference documentation](https://docs.spring.io/spring-boot/4.0/)
- [Spring Security migration documentation](https://docs.spring.io/spring-security/reference/migration/)
- [JEP 491: Synchronize Virtual Threads without Pinning](https://openjdk.org/jeps/491)

## License

MIT
