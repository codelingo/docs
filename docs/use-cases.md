# Use Cases

#### Detecting Memory Leaks
In the example below we have a database manager class that wraps up a library for returning connections to a SQL database.

Based off of past profiles of our application, we expect the function to use 10MB or less. If it uses more than this, we want to be notified.
 
Some time in the future we decide to update our library to the latest version.

On our next profile of our application, CLQL catches that the function has exceeded the limit multiple times.

As we iterate over the issues that are returned we see a steady increase in the memory consumed by the function, meaning a memory leak is likely and should be investigated further.

```
<cs.method:
  name: "getDBCon"
  file: "./db/manager.cs"
  prof:
    memory: <= 10MB
```

<br />

#### Detecting Race Conditions
In the example below we have a database manager class that we use to update and read user records.

If a getUser call is made while an updateUser call is in progress, the updateCall needs to returns before the getCall to ensure the updated data is being returned.

The tenet below will raise an issue if the getUser call finishes before the updateUser call since it's likely outdated data has been read.


```
<cs.method:
  name: "updateUser"
  file: "./db/manager.cs"
  prof:
    end_time: < cs.method:
      name: "getUser"
      file: "./db/manager.cs"
```

<br />

#### Detecting Deadlock