# Runtime

Runtime lexicons are used to query the runtime data of a program. These are typically used to identify performance issues and common runtime problems.

### Detecting Memory Leaks

In the example below we have a database manager class that wraps up a third party library we use to return connections to a database.

From past profiles of our application, we expect the function `getDBCon` to use less than 10MB of memory. If it uses more than this, we want to be notified.

We can do this with the following Tenet:

```clql
csprof.session:
  csprof.exec:
      command: "./scripts/build.sh"
      args: "-o ./bin/program.exe"
  csprof.exec:
    command: "./bin/program.exe"
    args: "/host:127.0.0.1 /db:testing"
  cs.file:
    filename: "./db/manager.cs"
    <cs.method:
      name: "getDBCon"
      csprof.exit:
        memory_mb: >= 10
```
 
Sometime in the future we decide to update the underlying library to the latest version. After profiling our application again, CodeLingo catches that multiple instances of the `getDBCon` function have exceeded the `>= 10MB memory` Tenet.

As we iterate over the issues, we see a steady increase in the memory consumed by the `getDBCon` function. Knowing that this didn't happen with the older version of the library, we suspect a memory leak may have been introduced in the update and further investigation is required.

Note: CLQL is able to assist in pin-pointing the source of memory leaks, but that is outside the scope of this use case.

<br />

### Detecting Race Conditions
In the example below we have a database manager class that we use to update and read user records.

Our application has a number of different workers that operate asynchronously, making calls to the database manager at any time.

We need to know if our database manager is handling the asynchronous calls correctly, so we write a tenet below to catch potential race conditions between two functions used by the workers:


```clql
csprof.session:
  csprof.exec:
    command: "./scripts/build.sh"
    args: "-o ./bin/program.exe"
  csprof.exec:
    command: "./bin/program.exe"
    args: "/host:127.0.0.1 /db:testing"
  cs.file:
    filename: "./db/manager.cs"
    cs.method:
      name: "updateUser"
      csprof.block_start:
        time: $startUpdate
      csprof.block_exit:
        time: $exitUpdate
    <cs.method:
      name: "getUser"
      csprof.block_start:
        time: > $startUpdate
      csprof.block_start:
        time: < $exitUpdate
```

This query users [variables](clql.md#variables) If the `getUser` function is called while an instance of the `updateUser` function is in progress, the `getUser` function must return after the `updateUser` function to prevent a dirty read from the database. An issue will be raised if this does not hold true.

<br />

### Detecting Deadlocks

In the example below, we have an application used for importing data into a database from a number of different sources asynchronously. The `importData` function is particularly resource heavy on our server due to the raw amount of data that needs to be processed. Knowing this, we decide to write a Tenet to catch any idle instances of the `importData` function:

```clql
cs.session:
  csprof.exec:
    command: "./scripts/build.sh"
    args: "-o ./bin/program.exe"
  csprof.exec:
    command: "./bin/program.exe"
    args: "/host:127.0.0.1 /db:testing"
  cs.file:
    filename: "./db/manager.cs"
    <cs.method:
      name: "importData"
      csprof.duration:
        time_min: >= 4
        average_cpu_percent: <= 1
        average_memory_mb: <= 10
```

If an instance of the `importData` runs for more than 4 minutes with unusually low resource usage, an issue will be raised as the function is suspect of deadlock.

<br />
