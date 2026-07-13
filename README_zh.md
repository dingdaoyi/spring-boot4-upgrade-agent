# Spring Boot 4 升级 Agent 技能包

> **把这个技能装载到你的 AI 编程助手里，它就能像一个资深的 Spring Boot 升级专家一样工作。**
>
> 21 个经过生产验证的运行时陷阱。来自多个大规模项目的真实升级经验。

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 为什么需要这个技能？

Spring Boot 官方迁移指南覆盖的是 API 层面的 breaking change。但真正的升级陷阱藏在运行时：

- 第三方 starter 的二进制不兼容（编译通过，启动必炸）
- BOM 导入顺序导致依赖版本静默降级
- Jackson 2→3 的转换器优先级战
- Flyway/Liquibase 的数据库版本门槛
- ServiceLoader SPI 注册（编译器完全看不到）
- JRE 容器 vs JDK 环境的差异（dev 跑通，prod CrashLoop）
- 虚拟线程在负载下的 pinning 问题

## 这个技能做什么？

1. **升级前审计** — 扫描项目中的已知兼容性问题，在动版本号之前就发现
2. **阶梯式迁移** — 先升到最新的 3.5.x，再跨主版本；每次只改一个兼容层
3. **运行时验证** — 不只检查编译，还要启动、跑测试、验证健康检查
4. **故障诊断** — 从第一条 `Caused by` 开始分类排查，匹配已知陷阱

## 快速开始

### Codex
```bash
git clone https://github.com/dingdaoyi/spring-boot4-upgrade-agent.git
mkdir -p ~/.codex/skills
cp -R spring-boot4-upgrade-agent/skills/spring-boot4-upgrade ~/.codex/skills/
```

然后这样调用：
```text
使用 $spring-boot4-upgrade 审计这个 Maven 项目并制定 Spring Boot 4 迁移计划
```

### Claude Code
```text
/plugin marketplace add dingdaoyi/spring-boot4-upgrade-agent
/plugin install spring-boot4-upgrade@spring-boot4-upgrade
```

### 直接运行审计脚本
```bash
bash skills/spring-boot4-upgrade/scripts/upgrade-audit.sh /path/to/project
```

## 覆盖范围

| 分类 | 内容 |
|------|------|
| 构建系统 | Maven/Gradle、BOM 顺序、依赖版本冲突、字节码故障诊断 |
| 模块化 | 新 starter 拆分表、测试 starter、classic 桥接器 |
| Jackson 3 | 包路径迁移、兼容层策略、序列化验证 |
| Spring Security 7 | Lambda DSL 迁移、CSRF 变化、授权规则 |
| 测试 | @MockitoBean、MockMvc、TestRestTemplate |
| 运行时 | 虚拟线程、JVM 标志、容器镜像、数据库 SSL |
| K8s 部署 | CrashLoop 诊断、就绪探针、rollout 验证 |

## 设计原则

- **先升 3.5.x 再跨主版本** — 不要跳过中间版本
- **以官方迁移指南和 BOM 为权威来源** — 不靠社区过时的版本表
- **不把 TLS/CSRF/数据库迁移关掉作为通用修复** — 诊断清楚再处理
- **不推送、不发布、不部署** — 除非你明确要求

## 谁做的

[丁云伟](https://github.com/dingdaoyi) — [Simple IoT](https://github.com/dingdaoyi/simple-iot) 作者。从 Spring Boot 3 到 4.1 升级了 20+ 个微服务，每个陷阱都是在生产环境踩出来的。同时整合了社区经验：[ankurm.com](https://ankurm.com/spring-boot-3-to-4-migration-guide/)、[spring-boot-4-migration-skill](https://github.com/adityamparikh/spring-boot-4-migration-skill)、[Medium/JavaRevisited](https://medium.com/javarevisited/spring-boot-4-migration-guide-what-breaks-and-how-to-fix-it-60373ca4683e)、[Coding Steve](https://stevenpg.com/posts/ultimate-guide-spring-boot-4-migration/)、[OpenRewrite](https://docs.openrewrite.org/recipes/java/spring/boot4/upgradespringboot_4_0-community-edition) 等社区最佳实践。

## 企业支持

技能包开源免费（MIT）。如果你需要**手把手的升级协助**、**项目定制审计报告**或**内部 Agent 训练**，开 GitHub Issue 或直接联系。

## License

MIT — 个人和商业使用均免费。
