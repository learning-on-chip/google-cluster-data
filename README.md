# Google Cluster Data

The repository contains scripts for dumping the workload traces of a computer
cluster [published][1] by Google into an SQLite database. The following tables
are currently processed:

* `job_events`,
* `task_events`, and
* `task_usage`.

## Usage

```bash
make
```

## Contribution

1. Fork the project.
2. Implement your idea.
3. Open a pull request.

[1]: https://github.com/google/cluster-data
