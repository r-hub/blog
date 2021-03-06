---
slug: rsqlite-parallel
title: "RSQLite concurrency issues — solution included"
authors: 
- Gábor Csárdi
date: "2021-03-13"
tags: 
- SQLite
- RSQLite
- databases
- concurrency
- parallel
output: hugodown::hugo_document
rmd_hash: 6a2093c8a9527a78

---

[SQLite](https://www.sqlite.org/index.html) is a great, full featured SQL database engine. Most likely it is used more than [all other database engines combined](https://www.sqlite.org/mostdeployed.html). The [RSQLite](https://rsqlite.r-dbi.org/) R package embeds SQLite, and lets you query and manipulate SQLite databases from R. It is used in Bioconductor data packages, many deployed Shiny apps, and several other packages and projects. In this post I show how to make it safer to use RSQLite concurrently, from multiple processes.

Note that this is an oversimplified description of how SQLite works and I will not talk about different types of locks, WAL mode, etc. Please see the SQLite documentation for the details.

## TL;DR

-   Always set the SQLite busy timeout.
-   If you use Unix, update RSQLite to at least version 2.2.4.
-   Use `IMMEDIATE` write transactions. (You can make use of the `dbWithWriteTransaction()` function at the end of this post.)

## Concurrency in SQLite

SQLite (and RSQLite) supports concurrent access to the same database, through multiple database connections, possibly from multiple processes. When multiple connections write to the database, SQLite, *with your help*, makes sure that the write operations are performed in a way that preserves the integrity of the database. SQLite makes sure that each query is atomic, and that the database file is never left in a corrupt state. Your job is to group the queries into transactions, so that the database is also kept consistent at the application level.

## The busy timeout

SQLite uses locks to allow only one write transaction at a time. When a second connection is trying to write to the database, while another connection has locked it already, SQLite by default returns an error and aborts the second write operation.

This default behavior is most often not acceptable, and you can do better. SQLite lets you set a [*busy timeout*](https://www.sqlite.org/pragma.html#pragma_busy_timeout)*.* If this timeout is set to a non-zero value, then the second connection will re-try the write operation several times, until it succeeds or the timeout expires.

To set the busy timeout from RSQLite, you can set a `PRAGMA` :

``` r
dbExecute(con, "PRAGMA busy_timeout = 10 * 1000")
```

This is in milliseconds, and it is best to set it right after opening the connection. (You can also use the new [`sqliteSetBusyHandler()`](https://rsqlite.r-dbi.org/reference/sqliteSetBusyHandler.html) function to set the busy timeout.)

Note that SQLite currently does *not* schedule concurrent transactions fairly. More precisely it does not schedule them at all. If multiple transactions are waiting on the same database, any one of them can be granted access next. Moreover, SQLite does not currently ensure that access is granted as soon as the database is available. Multiple connections might be waiting on the database, even if it is available. Make sure that you set the busy timeout to a high enough value for applications with high concurrency and many writes. It is fine to set it to several minutes, especially if you have made sure that your application does not have a deadlock (see later).

## The `usleep()` issue

Unfortunately RSQLite version before 2.2.4 had an issue that prevented good concurrent (write) database performance on Unix. When a connection waits on a lock, it uses the [`usleep()`](https://man7.org/linux/man-pages/man3/usleep.3.html) C library function on Unix, but only if SQLite was compiled with the `HAVE_USLEEP` compile-time option. Previous RSQLite versions did not set this option, so SQLite fell back to using the [`sleep()`](https://man7.org/linux/man-pages/man3/sleep.3.html) C library function instead. [`sleep()`](https://man7.org/linux/man-pages/man3/sleep.3.html) , however can only take an integer number of seconds. Sleeping at least one second between retries is obviously very bad for performance, and it also reduces the number of retries before a certain busy timeout expires, resulting in much more errors. (Or you had to set the timeout to a very large value.)

Several people experienced this over the years, and we also ran into it in the [liteq package](https://github.com/r-lib/liteq/issues/28). Luckily, this time [Iñaki Ucar](https://github.com/Enchufa2) was persistent enough to track down the issue. The [solution](https://github.com/r-dbi/RSQLite/pull/345) is simple enough: turn on the `HAVE_USLEEP` option. ([`usleep()`](https://man7.org/linux/man-pages/man3/usleep.3.html) was not always available in the past, but nowadays it is, so we don't actually have to check for it.)

If you have concurrency issues with RSQLite, please update to version 2.2.4 or later.

## Avoiding deadlocks

Even after updating RSQLite and setting the busy timeout, you can still get `database is locked` errors. This is because in some situations, these errors are the only way to avoid a deadlock. When SQLite detects an unavoidable deadlock, it will not use the busy timeout, but cancels some transactions.

By default SQLite transactions are `DEFERRED`, which means that they don't actually start with the `BEGIN` statement, but only with the first operation. If a transaction starts out with a read operation, SQLite assumes that it is a read transaction. If it performs a write operation later, then SQLite tries to upgrade it to a write transaction. Consider two concurrent `DEFERRED` transactions that both start out as read transactions, and then they both upgrade to write transactions. One of them (say the first one) will be upgraded, but the second one will be denied with a busy error, as there can be only one write transactions at a time. We cannot keep the second transaction and retry it later, because the second connection already holds a read lock, and this would not lot the first transaction commit its write operations. Neither transactions can continue, unless the other is canceled, so SQLite will cancel the second and let the first one commit. When the second one is canceled, its busy timeout is simply ignored, as it does not make sense to retry it. (The first transaction can be re-tried, however, using the busy timeout.)

One way to avoid deadlocks is to announce write transactions right when they start, with `BEGIN IMMEDIATE`. If all write-transactions are immediate transactions, then no deadlock can occur. (Well, at least not at this level.) Immediate transactions slightly reduce the the concurrency in your application, but often this is a good trade off to avoid deadlocks.

As far as I can tell there is no way to use immediate transactions in RSQLite with `dbWithTransaction()`, but you can create a helper function for it. It could look something like this:

``` r
#' @importFrom DBI dbExecute

dbWithWriteTransaction <- function(conn, code) {
  dbExecute(conn, "BEGIN IMMEDIATE")
  rollback <- function(e) {
    call <- dbExecute(conn, "ROLLBACK")
    if (identical(call, FALSE)) {
      stop(paste(
        "Failed to rollback transaction.",
        "Tried to roll back because an error occurred:",
        conditionMessage(e)
      ), call. = FALSE)
    }
    if (inherits(e, "error")) stop(e)
  }
  tryCatch(
    {
      res <- force(code)
      dbExecute(conn, "COMMIT")
      res
    },
    db_abort = rollback,
    error = rollback,
    interrupt = rollback
  )
}
```

## Links

-   [About the SQLite busy timeout, see also links within.](https://www.sqlite.org/c3ref/busy_timeout.html)

-   [Nice blog post about concurrency in SQLite](https://activesphere.com/blog/2018/12/24/understanding-sqlite-busy)

-   [Blog post about the `usleep()` mishap](https://beets.io/blog/sqlite-nightmare.html)

-   [RSQLite on GitHub](https://github.com/r-dbi/RSQLite)

