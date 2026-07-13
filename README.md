# Spring Boot 4 Upgrade Agent · Spring Boot 4 升级 Agent 技能包

> **Drop this skill into your AI coding agent. It becomes a Spring Boot upgrade expert.**
> **把这个技能装载到 AI 编程助手里，它就能像资深 Spring Boot 升级专家一样工作。**
>
> 21 production-verified runtime traps. 21 个经过生产验证的运行时陷阱。

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

**English** | [中文](#中文)

## Why · 为什么需要

Spring Boot's official migration guide covers API changes. Real upgrades break at runtime from:
官方迁移指南覆盖 API 变更。真正的升级陷阱藏在运行时：

- Third-party starter binary incompatibilities · 第三方 starter 二进制不兼容
- BOM ordering silently swapping dependency versions · BOM 顺序导致版本静默降级
- Jackson 2→3 converter precedence bugs · Jackson 2→3 转换器优先级问题
- Database version gates in Flyway · Flyway 数据库版本门槛
- ServiceLoader SPI failures invisible to javac · ServiceLoader 故障编译期看不到
- JRE vs JDK container startup crashes · JRE/JDK 容器差异导致启动失败
- Virtual thread pinning under load · 虚拟线程负载下的 pinning

## Quick Start · 快速开始

### Codex
```bash
git clone https://github.com/dingdaoyi/spring-boot4-upgrade-agent.git
mkdir -p ~/.codex/skills
cp -R spring-boot4-upgrade-agent/skills/spring-boot4-upgrade ~/.codex/skills/
```
```text
Use $spring-boot4-upgrade to audit this Maven project and plan a Spring Boot 4 migration.
使用 $spring-boot4-upgrade 审计这个 Maven 项目并制定 Spring Boot 4 迁移计划。
```

### Claude Code
```text
/plugin marketplace add dingdaoyi/spring-boot4-upgrade-agent
/plugin install spring-boot4-upgrade@spring-boot4-upgrade
```

### Direct Audit · 直接审计
```bash
bash skills/spring-boot4-upgrade/scripts/upgrade-audit.sh /path/to/project
```

## Coverage · 覆盖范围

| 分类 Category | 内容 Content |
|------|------|
| Build · 构建 | Maven/Gradle, BOM ordering, dependency conflicts, bytecode diagnosis |
| Modularization · 模块化 | Starter rename table, test companions, classic bridges |
| Jackson 3 | Package migration, compatibility strategy, serialization validation |
| Security 7 · 安全 | Lambda DSL, CSRF changes, authorization rules |
| Testing · 测试 | @MockitoBean, MockMvc, TestRestTemplate |
| Runtime · 运行时 | Virtual threads, JVM flags, container images, DB SSL |
| K8s | CrashLoop diagnosis, readiness probes, rollout verification |

## Design Principles · 设计原则

- Upgrade to latest 3.5.x before crossing the major-version boundary · 先升 3.5.x 再跨主版本
- Treat the official migration guide and BOM as authoritative · 以官方迁移指南和 BOM 为权威来源
- Don't disable TLS/CSRF/migrations as generic workaround · 不把安全开关关掉当通用修复
- Don't push, publish, or deploy unless explicitly asked · 未经允许不推送不发布不部署

## Sources · 来源

Production experience + community best practices:
生产经验 + 社区最佳实践：
- [ankurm.com](https://ankurm.com/spring-boot-3-to-4-migration-guide/)
- [spring-boot-4-migration-skill](https://github.com/adityamparikh/spring-boot-4-migration-skill)
- [Medium/JavaRevisited](https://medium.com/javarevisited/spring-boot-4-migration-guide-what-breaks-and-how-to-fix-it-60373ca4683e)
- [Coding Steve](https://stevenpg.com/posts/ultimate-guide-spring-boot-4-migration/)
- [OpenRewrite Boot 4 Migration](https://docs.openrewrite.org/recipes/java/spring/boot4/upgradespringboot_4_0-community-edition)
- Official [Spring Boot 4.0 Migration Guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-4.0-Migration-Guide)

## Author · 作者

[Yunwei Ding (丁云伟)](https://github.com/dingdaoyi) — Creator of [Simple IoT](https://github.com/dingdaoyi/simple-iot). Upgraded 20+ microservices from Spring Boot 3 to 4.1. Each trap was found the hard way — in production.
[Simple IoT](https://github.com/dingdaoyi/simple-iot) 作者。从 Spring Boot 3 到 4.1 升级了 20+ 个微服务，每个坑都是在生产环境踩出来的。

## License · 许可证

MIT — Free for personal and commercial use. Enterprise support available.
个人和商业使用均免费。企业支持可联系。

---

## 中文

### 这个技能做什么？

1. **升级前审计** — 扫描项目中的已知兼容性问题
2. **阶梯式迁移** — 先升 3.5.x，再跨主版本；每次只改一个兼容层
3. **运行时验证** — 不只检查编译，还要启动、跑测试、验证健康检查
4. **故障诊断** — 从第一条 `Caused by` 开始分类排查，匹配已知陷阱

### 安装方式

**Codex**：clone 仓库 → 复制 `skills/spring-boot4-upgrade` 到 `~/.codex/skills/`

**Claude Code**：添加 marketplace 后 `/plugin install`

**直接运行**：`bash skills/spring-boot4-upgrade/scripts/upgrade-audit.sh <项目路径>`

### 覆盖的陷阱

21 个经过生产验证的运行时陷阱，涵盖：依赖冲突、Jackson 3 迁移、Security 7 Lambda DSL、虚拟线程 pinning、JVM 标志、容器配置、K8s CrashLoop 诊断、OpenAPI/Knife4j 兼容性、PostgreSQL SSL、数据库迁移版本门槛等。

### 谁做的

丁云伟 — Simple IoT 作者。升级了 20+ 个 Spring Boot 微服务，也整合了 ankurm.com、adityamparikh/spring-boot-4-migration-skill、OpenRewrite 等社区经验。
