# Implementation & Performance Notes

## Design choices
- **Business rules live in the database**: capacity, uniqueness, valid score range and valid status are enforced by constraints; procedures add checks and translate failures into meaningful application errors.
- **Errors are never hidden.** Each procedure/function maps expected failures to specific `RAISE_APPLICATION_ERROR` codes. `WHEN OTHERS` re-raises existing application errors untouched and wraps anything else as `-20099` including the original `SQLERRM`. Functions raise errors rather than returning `NULL`/`0`, so callers cannot mistake "no data" for "zero".
- **Transaction control**: procedures `COMMIT` on success and `ROLLBACK` on unexpected failure. `apply_score_curve` has a `p_commit` flag so tests can inspect changes and roll back.

## Records, collections, cursors
- `%ROWTYPE` for whole rows (`students%ROWTYPE`, cursor `%ROWTYPE`); user-defined records where only some columns are needed.
- Associative array (`INDEX BY VARCHAR2`) counts grades by letter; nested table `t_number_list` is a schema type so it can be a parameter, a return value and be queried with `TABLE()`; BULK COLLECT creates local nested tables.
- Implicit cursor attributes are read **immediately** after the DML statement they describe (any later SQL statement overwrites them).
- `compute_letter_grades` uses an explicit cursor with `FOR UPDATE` / `WHERE CURRENT OF` (locks rows while processing, no second lookup). It COMMITs only after the cursor is closed.

## Bulk processing
Each SQL statement executed from PL/SQL causes a **context switch** between the PL/SQL engine and the SQL engine. A loop that issues one `UPDATE` per row pays that cost N times. `BULK COLLECT` fetches all rows in one switch and `FORALL` sends the whole collection to the SQL engine in one switch, which reduces CPU time, round trips and parse/execute overhead.

- `FORALL ... SAVE EXCEPTIONS` keeps going after a failing row; failures are available in `SQL%BULK_EXCEPTIONS` (`ERROR_INDEX`, `ERROR_CODE`) and ORA-24381 is raised once at the end. Without it, the first error would abort the statement.
- `SQL%ROWCOUNT` after `FORALL` is the total number of rows affected.
- **Memory**: BULK COLLECT loads everything into PGA memory. For very large tables use `FETCH ... BULK COLLECT INTO ... LIMIT n` in a loop (e.g. 1000-5000). Our class-size data sets are small, so a single fetch is fine.
- Limits: `FORALL` runs one DML statement, and the index set must be dense (or use `INDICES OF`).

### Measured results (fill in after running `benchmark_bulk_update(50000)`)

| Rows | Row-by-row (ms) | BULK COLLECT + FORALL (ms) | Speed-up |
|------|-----------------|----------------------------|----------|
| 50 000 | _..._ | _..._ | _..._x |

(Include a screenshot: `screenshots/S10_benchmark_output.png`. Results vary by machine; the bulk version is normally many times faster.)

## Known limitations
- `bulk_enroll_students` does not check student status (a suspended student could be bulk-enrolled); `register_student_course` does.
- Letter-grade thresholds (90/80/70/60) are hard-coded in `get_letter_grade`; a production system would read them from a table.
