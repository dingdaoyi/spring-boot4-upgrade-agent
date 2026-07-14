# Spring Boot 4 Upgrade

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[中文](#中文) · [English](#english)

---

<a id="中文"></a>

## 中文

一个以证据为依据的 AI Agent Skill，用于把 Spring Boot 3.5 应用升级到 Spring Boot 4.x。它覆盖依赖对齐、源码迁移、运行时故障诊断和发布验证，不会把“编译通过”误判成“升级完成”。

### 能做什么

- 审计 Maven 或 Gradle 项目的升级风险
- 迁移 Spring Boot 4 模块化 Starter 和包结构
- 制定 Jackson 3 迁移或临时 Jackson 2 兼容策略
- 迁移 Spring Security 7 和 Spring Boot 测试基础设施
- 排查 `ClassNotFoundException`、`NoSuchMethodError` 等二进制兼容问题
- 检查数据库迁移、JVM、容器、虚拟线程和 Kubernetes 部署
- 通过真实启动、接口、序列化、安全和数据库行为验证升级结果

这套 Skill 不维护一张容易过时的“万能第三方版本表”。它要求 Agent 根据目标 Spring Boot 维护版本、上游兼容说明和项目实际解析出的依赖图做判断。

### 安装

#### 通用安装（推荐）

使用 [Skills CLI](https://skills.sh/) 安装。CLI 会识别仓库中的 `spring-boot4-upgrade`，并安装到你选择的 Agent：

```bash
npx skills add dingdaoyi/spring-boot4-upgrade-agent
```

无人值守安装到 Codex 的全局 Skill 目录：

```bash
npx skills add dingdaoyi/spring-boot4-upgrade-agent \
  --skill spring-boot4-upgrade --agent codex --global --yes --copy
```

#### Codex 手动安装

```bash
git clone https://github.com/dingdaoyi/spring-boot4-upgrade-agent.git
mkdir -p ~/.codex/skills
cp -R spring-boot4-upgrade-agent/skills/spring-boot4-upgrade ~/.codex/skills/
```

调用示例：

```text
Use $spring-boot4-upgrade to audit this project and plan a Spring Boot 4 migration.
```

#### Claude Code

```text
/plugin marketplace add dingdaoyi/spring-boot4-upgrade-agent
/plugin install spring-boot4-upgrade@spring-boot4-upgrade
```

本地开发时，也可以在仓库根目录执行：

```bash
claude --plugin-dir .
```

完整的 Skill 命令为 `/spring-boot4-upgrade:spring-boot4-upgrade`。

#### GitHub Copilot CLI

Copilot CLI 可以直接从 GitHub 仓库安装这个插件：

```bash
copilot plugin install dingdaoyi/spring-boot4-upgrade-agent
```

安装完成后，可在 Copilot CLI 中通过 `/skills list` 确认 `spring-boot4-upgrade` 已加载。

#### 直接运行升级审计

```bash
bash skills/spring-boot4-upgrade/scripts/upgrade-audit.sh /path/to/project
```

审计脚本默认只输出建议，不会因为发现风险而返回失败。需要用于 CI 门禁时添加 `--strict`：

```bash
bash skills/spring-boot4-upgrade/scripts/upgrade-audit.sh --strict /path/to/project
```

### 覆盖范围

| 分类 | 内容 |
|---|---|
| 构建与依赖 | Maven、Gradle、BOM、依赖收敛、字节码诊断 |
| 模块化 | Starter 重命名、聚焦模块、测试 Starter、Classic 过渡方案 |
| Jackson | Jackson 3 原生迁移、Jackson 2 临时兼容、序列化验证 |
| Security | Spring Security 7 Lambda DSL、授权与 CSRF 行为验证 |
| 测试 | `@MockitoBean`、MockMvc、TestRestTemplate、RestTestClient |
| 运行时 | JVM、容器镜像、虚拟线程、PostgreSQL TLS |
| 部署 | Kubernetes CrashLoop、探针、镜像和 Rollout 验证 |

### 仓库结构

```text
.
├── .claude-plugin/                 # Claude Code 插件与 marketplace 元数据
├── skills/
│   └── spring-boot4-upgrade/       # 可独立安装的 Skill
│       ├── SKILL.md
│       ├── agents/openai.yaml
│       ├── references/
│       └── scripts/
├── LICENSE
└── README.md
```

### 设计原则

- 跨主版本前，先升级到适用的最新 Spring Boot 3.5.x 维护版本。
- 以官方迁移指南、目标版本的依赖管理和项目实际依赖图为准。
- 分阶段迁移，每一层修改都保留可归因的验证结果。
- 不把关闭 TLS、CSRF、数据库迁移或兼容性检查当作通用修复。
- 没有明确的运行时异常和依赖要求，不随意添加 `--add-opens` 或 Unsafe 相关 JVM 参数。
- 除非用户明确要求，否则不提交、不推送、不发布、不部署。

### 主要资料

- [Spring Boot 4.0 官方迁移指南](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-4.0-Migration-Guide)
- [Spring Boot 4 参考文档](https://docs.spring.io/spring-boot/4.0/)
- [Spring Security 迁移文档](https://docs.spring.io/spring-security/reference/migration/)
- [JEP 491：虚拟线程与 synchronized](https://openjdk.org/jeps/491)

### 作者与许可证

作者：[dingdaoyi](https://github.com/dingdaoyi)

采用 [MIT License](LICENSE)，可用于个人和商业项目。

---

<a id="english"></a>

## English

An evidence-first AI agent skill for upgrading Spring Boot 3.5 applications to Spring Boot 4.x. It covers dependency alignment, source migration, runtime diagnosis, and release verification without treating a successful compile as proof that the upgrade is complete.

### What it does

- Audits Maven or Gradle projects for upgrade risks
- Migrates Spring Boot 4 modular starters and package changes
- Plans a native Jackson 3 migration or a temporary Jackson 2 bridge
- Migrates Spring Security 7 and Spring Boot test infrastructure
- Diagnoses binary compatibility failures such as `ClassNotFoundException` and `NoSuchMethodError`
- Reviews database migration, JVM, container, virtual-thread, and Kubernetes concerns
- Verifies the result through real startup, API, serialization, security, and database behavior

The skill does not maintain a supposedly universal third-party version table. It asks the agent to verify the selected Spring Boot maintenance release, upstream compatibility statements, and the project's resolved dependency graph.

### Installation

#### Universal installation (recommended)

Install with the [Skills CLI](https://skills.sh/). The CLI discovers `spring-boot4-upgrade` in this repository and installs it for the agent you select:

```bash
npx skills add dingdaoyi/spring-boot4-upgrade-agent
```

For an unattended global Codex installation:

```bash
npx skills add dingdaoyi/spring-boot4-upgrade-agent \
  --skill spring-boot4-upgrade --agent codex --global --yes --copy
```

#### Manual Codex installation

```bash
git clone https://github.com/dingdaoyi/spring-boot4-upgrade-agent.git
mkdir -p ~/.codex/skills
cp -R spring-boot4-upgrade-agent/skills/spring-boot4-upgrade ~/.codex/skills/
```

Example prompt:

```text
Use $spring-boot4-upgrade to audit this project and plan a Spring Boot 4 migration.
```

#### Claude Code

```text
/plugin marketplace add dingdaoyi/spring-boot4-upgrade-agent
/plugin install spring-boot4-upgrade@spring-boot4-upgrade
```

For local development, run this from the repository root:

```bash
claude --plugin-dir .
```

The fully qualified skill command is `/spring-boot4-upgrade:spring-boot4-upgrade`.

#### GitHub Copilot CLI

Copilot CLI can install the plugin directly from its GitHub repository:

```bash
copilot plugin install dingdaoyi/spring-boot4-upgrade-agent
```

After installation, run `/skills list` in Copilot CLI to confirm that `spring-boot4-upgrade` is loaded.

#### Run the audit directly

```bash
bash skills/spring-boot4-upgrade/scripts/upgrade-audit.sh /path/to/project
```

The audit is advisory by default. Add `--strict` when warnings should produce a non-zero exit code in CI:

```bash
bash skills/spring-boot4-upgrade/scripts/upgrade-audit.sh --strict /path/to/project
```

### Coverage

| Area | Coverage |
|---|---|
| Build and dependencies | Maven, Gradle, BOMs, dependency convergence, bytecode diagnosis |
| Modularization | Renamed starters, focused modules, test starters, classic migration bridge |
| Jackson | Native Jackson 3 migration, temporary Jackson 2 bridge, serialization verification |
| Security | Spring Security 7 lambda DSL, authorization and CSRF behavior |
| Testing | `@MockitoBean`, MockMvc, TestRestTemplate, RestTestClient |
| Runtime | JVMs, container images, virtual threads, PostgreSQL TLS |
| Deployment | Kubernetes CrashLoops, probes, image identity, and rollout verification |

### Repository layout

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

### Design principles

- Upgrade to the latest applicable Spring Boot 3.5.x maintenance release before crossing the major-version boundary.
- Treat the official migration guide, target release dependency management, and resolved project graph as the source of truth.
- Migrate in stages and keep each verification result attributable.
- Do not disable TLS, CSRF, database migrations, or compatibility checks as a generic workaround.
- Do not add `--add-opens` or unsafe-memory JVM flags without a matching failure and documented dependency requirement.
- Do not commit, push, publish, or deploy unless the user explicitly asks.

### Primary references

- [Official Spring Boot 4.0 Migration Guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-4.0-Migration-Guide)
- [Spring Boot 4 reference documentation](https://docs.spring.io/spring-boot/4.0/)
- [Spring Security migration documentation](https://docs.spring.io/spring-security/reference/migration/)
- [JEP 491: Synchronize Virtual Threads without Pinning](https://openjdk.org/jeps/491)

### Author and license

Author: [dingdaoyi](https://github.com/dingdaoyi)

Released under the [MIT License](LICENSE) for personal and commercial use.
