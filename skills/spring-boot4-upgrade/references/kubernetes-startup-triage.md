# Kubernetes startup triage

Use this reference when an upgraded application enters `CrashLoopBackOff`, fails readiness, or appears healthy before restarting.

## Triage sequence

### 1. Capture rollout and image identity

```bash
kubectl -n <namespace> rollout status deployment/<deployment> --timeout=5m
kubectl -n <namespace> get pods -l app=<label> -o wide
kubectl -n <namespace> get pod <pod> -o jsonpath='{.status.containerStatuses[*].imageID}'
```

Confirm that the pod is running the expected immutable image and configuration revision. A completed CI build does not prove that the deployment pulled that artifact.

### 2. Inspect events and termination state

```bash
kubectl -n <namespace> describe pod <pod>
kubectl -n <namespace> get pod <pod> \
  -o jsonpath='{.status.containerStatuses[*].lastState.terminated}'
```

Distinguish application exit, out-of-memory termination, failed probes, image errors, permission failures, and node eviction.

### 3. Read current and previous logs

```bash
kubectl -n <namespace> logs <pod> --all-containers --tail=300
kubectl -n <namespace> logs <pod> --all-containers --previous --tail=300
```

Capture the first meaningful cause chain and timestamps. If there is no previous container, use current logs. Avoid `kubectl exec` against a container that exits before a shell can start.

### 4. Compare environment deltas

Check:

- Java version, architecture, JVM flags, memory limits, and entry point;
- ConfigMaps, Secrets, environment variables, mounted files, and service-account permissions;
- database, broker, DNS, certificate, and proxy connectivity;
- startup, readiness, and liveness probe paths, ports, schemes, delays, and thresholds;
- migration locks and startup work that may exceed probe timing.

Do not print secret values. Compare names, hashes, presence, and mount locations instead.

### 5. Map the first cause to a focused investigation

| Evidence | Next step |
|---|---|
| Missing class or method | Inspect runtime dependency graph and image contents |
| Bean or configuration binding failure | Check modular starter, relocated type, and effective properties |
| Database migration error | Stop restart churn, inspect migration state, and coordinate recovery |
| TLS or authentication EOF | Compare client, server, proxy, and certificate evidence |
| Probe failure with a running process | Test the probe from inside the pod or an approved debug container |
| Exit code 137 or OOM event | Inspect container and node memory, heap settings, and native memory |

### 6. Prove stability

Do not treat a momentary `1/1 Running` state as success. Verify that:

- restart counts stop increasing;
- the rollout completes;
- readiness remains true beyond the startup window;
- health and critical APIs work;
- logs contain the expected startup marker and no repeating fatal error;
- metrics show stable memory and connection behavior.

Record the deployed image digest and verification time in the migration report.
