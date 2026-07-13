# Spring Boot 4 Upgrade Agent

> **Drop this skill into your AI coding agent. It becomes a Spring Boot upgrade expert.**
>
> 21 production-verified runtime traps. Compiled from upgrading 20+ microservices.

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[中文版](#中文版)

---

## Why

The official migration guide covers API changes. Real upgrades break at runtime from:

- Third-party starter binary incompatibilities
- BOM ordering silently swapping dependency versions
- Jackson 2→3 converter precedence bugs
- Database version gates in Flyway
- ServiceLoader SPI failures invisible to javac
- JRE vs JDK container startup crashes
- Virtual thread pinning under load

## Quick Start

### Codex
```bash
git clone https://github.com/dingdaoyi/spring-boot4-upgrade-agent.git
mkdir -p ~/.codex/skills
cp -R spring-boot4-upgrade-agent/skills/spring-boot4-upgrade ~/.codex/skills/
```
```
Use $spring-boot4-upgrade to audit this project and plan a Spring Boot 4 migration.
```

### Claude Code
```
/plugin marketplace add dingdaoyi/spring-boot4-upgrade-agent
/plugin install spring-boot4-upgrade@spring-boot4-upgrade
```

### Direct Audit
```bash
bash skills/spring-boot4-upgrade/scripts/upgrade-audit.sh /path/to/project
```

## Coverage

| Category | Content |
|----------|---------|
| Build | Maven/Gradle, BOM ordering, dependency conflicts, bytecode diagnosis |
| Modularization | Starter rename table, test companions, classic bridges |
| Jackson 3 | Package migration, compatibility strategy, serialization validation |
| Security 7 | Lambda DSL, CSRF changes, authorization rules |
| Testing | @MockitoBean, MockMvc, TestRestTemplate |
| Runtime | Virtual threads, JVM flags, container images, PostgreSQL SSL |
| K8s | CrashLoop diagnosis, readiness probes, rollout verification |

## Design Principles

- Upgrade to latest 3.5.x before crossing the major-version boundary
- Treat the official migration guide and BOM as the source of truth
- Don't disable TLS/CSRF/migrations as a generic workaround
- Don't push, publish, or deploy unless the user explicitly asks

## Sources

Production experience + community best practices:
- [Spring Boot 4.0 Migration Guide (official)](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-4.0-Migration-Guide)
- [ankurm.com migration guide](https://ankurm.com/spring-boot-3-to-4-migration-guide/)
- [spring-boot-4-migration-skill](https://github.com/adityamparikh/spring-boot-4-migration-skill)
- [Medium: What Breaks and How to Fix It](https://medium.com/javarevisited/spring-boot-4-migration-guide-what-breaks-and-how-to-fix-it-60373ca4683e)
- [Ultimate Guide to Spring Boot 4 Migration](https://stevenpg.com/posts/ultimate-guide-spring-boot-4-migration/)
- [OpenRewrite Boot 4 Migration Recipes](https://docs.openrewrite.org/recipes/java/spring/boot4/upgradespringboot_4_0-community-edition)

## Author

[Yunwei Ding](https://github.com/dingdaoyi) — Creator of [Simple IoT](https://github.com/dingdaoyi/simple-iot). Upgraded 20+ microservices from Spring Boot 3 to 4.1. Each trap was found the hard way — in production.

## License

MIT — Free for personal and commercial use. Enterprise support available.

---

## 中文版

Spring Boot 4 升级 Agent 技能包。把 21 个生产环境踩过的坑做成了 AI 编程助手可以直接用的技能文件。兼容 Claude Code、Codex CLI、Cursor。

### 为什么需要

Spring Boot 官方迁移指南只覆盖 API 变更。真正让你在凌晨三点被报警叫醒的，是这些运行时陷阱：

- 第三方 starter 二进制不兼容（编译通过，启动必炸）
- BOM 导入顺序导致依赖版本静默降级
- Jackson 2→3 转换器优先级问题
- Flyway 社区版悄悄丢弃 MySQL 5.7 支持
- ServiceLoader SPI 注册（javac 完全看不到）
- JRE 容器 vs JDK 环境的差异（本地跑通，K8s CrashLoop）
- 虚拟线程在负载下被 `synchronized` pin 住

### 安装

**Codex**：clone 仓库 → 复制 `skills/spring-boot4-upgrade` 到 `~/.codex/skills/`

**Claude Code**：`/plugin marketplace add` → `/plugin install`

**直接运行审计**：`bash skills/spring-boot4-upgrade/scripts/upgrade-audit.sh <项目路径>`

### 覆盖范围

构建系统、模块化 starter 迁移、Jackson 3 迁移、Spring Security 7 Lambda DSL、测试基础设施（@MockitoBean / MockMvc）、虚拟线程 pinning、JVM 标志、容器镜像、K8s CrashLoop 诊断、OpenAPI/Knife4j 兼容性、PostgreSQL SSL、数据库迁移版本门槛。

### 设计原则

- 先升到最新 3.5.x，再跨主版本
- 以官方迁移指南和 BOM 为权威来源，不靠过时的版本表
- 不把安全开关关掉当通用修复
- 不推送、不发布、不部署（除非你明确要求）

### 来源

个人升级 20+ 微服务的一手经验 + 社区最佳实践：ankurm.com、adityamparikh/spring-boot-4-migration-skill、JavaRevisited、Coding Steve、OpenRewrite、Spring 官方迁移指南。

### 作者

[丁云伟](https://github.com/dingdaoyi) — [Simple IoT](https://github.com/dingdaoyi/simple-iot) 作者。MIT 开源。
