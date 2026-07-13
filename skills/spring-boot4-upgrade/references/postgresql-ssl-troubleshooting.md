# PostgreSQL TLS and EOF troubleshooting

Use this reference when PostgreSQL connections end during SSL negotiation or authentication with `EOFException`, `SSLHandshakeException`, or a generic connection failure.

## Do not infer the root cause from EOF alone

An EOF means the peer or an intermediary closed the connection. Possible causes include:

- the wrong host, port, protocol, or proxy route;
- server TLS being disabled or misconfigured;
- certificate, hostname, protocol, or cipher mismatch;
- a firewall, load balancer, service mesh, or database proxy closing the session;
- an authentication or `pg_hba.conf` rule;
- an incompatible or duplicated PostgreSQL JDBC driver;
- server resource pressure or restart.

Do not attribute the failure to Java 25 without comparative evidence.

## Diagnose in layers

1. Confirm the resolved driver and runtime:

   ```bash
   ./mvnw dependency:tree -Dincludes=org.postgresql:postgresql
   java -version
   ```

2. Confirm DNS and TCP routing from the same container or pod:

   ```bash
   getent hosts <database-host>
   nc -vz <database-host> 5432
   ```

3. Test with the PostgreSQL client using the same host, user, database, and SSL mode:

   ```bash
   PGSSLMODE=verify-full psql -h <database-host> -U <user> -d <database>
   ```

4. Compare client logs with PostgreSQL, proxy, and network logs at the same timestamp.
5. Inspect the effective JDBC URL and secret injection without printing passwords.

## Use SSL modes deliberately

PostgreSQL JDBC supports modes such as `disable`, `allow`, `prefer`, `require`, `verify-ca`, and `verify-full`. Confirm current semantics in the PostgreSQL JDBC documentation for the resolved driver.

Use `sslmode=disable` only as a controlled diagnostic or in an environment whose security design explicitly permits plaintext transport. A successful plaintext test shows that the failure is in the TLS path; it does not make disabling TLS an acceptable production fix.

For production, prefer certificate and hostname verification and fix the server, trust store, DNS name, or proxy configuration causing the handshake failure.

## Compare Java runtimes correctly

When the failure appears only after a Java upgrade:

- run the same driver, image contents, trust store, JDBC URL, and network path on both Java releases;
- enable targeted TLS diagnostics in a protected environment because debug logs can expose sensitive metadata;
- inspect removed or disabled algorithms and certificate validity;
- upgrade the JDBC driver to a release supporting the selected Java version before weakening TLS.

Record the exact delta that changes the result.
