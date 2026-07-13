# JSqlParser 4.x to 5.x migration

Use this reference only when the application directly imports JSqlParser APIs or owns SQL rewriting code. Libraries that merely depend on JSqlParser should normally be upgraded or replaced rather than patched locally.

## Table of contents

- [Verify the actual API](#verify-the-actual-api)
- [Inventory direct usage](#inventory-direct-usage)
- [Common structural changes](#common-structural-changes)
- [Migration sequence](#migration-sequence)
- [Verification corpus](#verification-corpus)

## Verify the actual API

Do not migrate from memory. Locate the exact resolved JAR and inspect the classes used by the project:

```bash
JAR=<path-to-resolved-jsqlparser-5.x.jar>

javap -classpath "$JAR" -p net.sf.jsqlparser.statement.select.Select
javap -classpath "$JAR" -p net.sf.jsqlparser.statement.select.PlainSelect
javap -classpath "$JAR" -p net.sf.jsqlparser.statement.select.ParenthesedSelect
javap -classpath "$JAR" -p net.sf.jsqlparser.statement.insert.Insert
javap -classpath "$JAR" -p net.sf.jsqlparser.expression.operators.relational.InExpression
```

Use the dependency tree to prove which version supplies that JAR. JSqlParser APIs can change between major and minor lines; the bytecode in the resolved artifact is authoritative for the current migration.

## Inventory direct usage

```bash
rg -n 'net\.sf\.jsqlparser|SelectBody|SubSelect|ItemsList|SelectExpressionItem|getItemsList|getSelectBody' \
  --glob '*.java' --glob '*.kt' .
```

Separate application-owned adapters from copied framework internals. Prefer the current extension API of MyBatis, Hibernate, or the owning framework over maintaining a fork of its SQL parser.

## Common structural changes

The following are migration signals, not a substitute for inspecting the selected JAR:

| Older usage | 5.x direction to inspect |
|---|---|
| `SelectBody` | `Select` hierarchy |
| `SubSelect` | `ParenthesedSelect` |
| `SelectExpressionItem` | generic `SelectItem<?>` |
| `ItemsList` and multi-expression list types | generic `ExpressionList<?>` and `Values` |
| `Insert.getItemsList()` | `Insert.getSelect()`, `getValues()`, and column expression lists |
| `InExpression.getRightItemsList()` | `getRightExpression()` |
| `WithItem.getSelectBody()` | parenthesized statement APIs |
| one-argument `Parenthesis` construction | builder or setter API exposed by the resolved version |

Avoid broad raw casts to silence generic errors. Model single-row values, multi-row values, select items, and columns with the types exposed by the resolved API, and add narrow helper methods when the library's wildcard signatures require them.

## Migration sequence

1. Compile against the selected 5.x artifact without changing runtime resolution.
2. Change traversal method parameters from removed interfaces to the current `Select` hierarchy.
3. Handle `PlainSelect`, `ParenthesedSelect`, set operations, and `Values` explicitly.
4. Update insert-value handling for single-row, multi-row, and `INSERT ... SELECT` forms.
5. Update subquery traversal in `FROM`, `JOIN`, CTE, and `IN` expressions.
6. Rebuild every library module that publishes the adapter before testing downstream applications.
7. Confirm that no submodule or plugin restores a 4.x JAR at runtime.

## Verification corpus

Parse and transform a representative corpus rather than one happy-path statement:

- simple `SELECT`, aliases, joins, nested subqueries, and correlated subqueries;
- `UNION` or other set operations;
- CTEs and recursive CTEs when supported by the application;
- `UPDATE` and `DELETE` with joins or subqueries;
- single-row and multi-row `INSERT ... VALUES`;
- `INSERT ... SELECT`;
- quoted identifiers, schema-qualified tables, parameters, vendor syntax, and comments.

Assert both that parsing succeeds and that the transformed SQL preserves semantics. Then run the real persistence path to catch runtime linkage errors and framework-specific traversal cases.
