#!/usr/bin/env python

import glob, os, sqlite3, subprocess, sys

schema = {
    'job_events': """
        DROP TABLE IF EXISTS `job_events`;
        CREATE TABLE `job_events` (
            `time` INTEGER NOT NULL,
            `missing info` INTEGER,
            `job ID` INTEGER NOT NULL,
            `event type` INTEGER NOT NULL,
            `user` TEXT,
            `scheduling class` INTEGER,
            `job name` TEXT,
            `logical job name` TEXT
        );
    """,

    'task_events': """
        DROP TABLE IF EXISTS `task_events`;
        CREATE TABLE `task_events` (
            `time` INTEGER NOT NULL,
            `missing info` INTEGER,
            `job ID` INTEGER NOT NULL,
            `task index` INTEGER NOT NULL,
            `machine ID` INTEGER,
            `event type` INTEGER NOT NULL,
            `user` TEXT,
            `scheduling class` INTEGER,
            `priority` INTEGER NOT NULL,
            `CPU request` REAL,
            `memory request` REAL,
            `disk space request` REAL,
            `different machines restriction` INTEGER
        );
    """,

    'task_usage': """
        DROP TABLE IF EXISTS `task_usage`;
        CREATE TABLE `task_usage` (
            `start time` INTEGER NOT NULL,
            `end time` INTEGER NOT NULL,
            `job ID` INTEGER NOT NULL,
            `task index` INTEGER NOT NULL,
            `machine ID` INTEGER NOT NULL,
            `CPU rate` REAL,
            `canonical memory usage` REAL,
            `assigned memory usage` REAL,
            `unmapped page cache` REAL,
            `total page cache` REAL,
            `maximum memory usage` REAL,
            `disk IO time` REAL,
            `local disk space usage` REAL,
            `maximum CPU rate` REAL,
            `maximum disk IO time` REAL,
            `cycles per instruction` REAL,
            `memory accesses per instruction` REAL,
            `sample portion` REAL,
            `aggregation type` INTEGER,
            `sampled CPU usage` REAL
        );
    """
}

sqlite3_path = 'google.sqlite3'
for table in sys.argv[1:]:
    sqlite3 = subprocess.Popen(['sqlite3', sqlite3_path], stdin=subprocess.PIPE)
    sqlite3.communicate(input=schema[table])
    sqlite3.wait()
    for csv_gz_path in sorted(glob.glob(os.path.join(table, '*.csv.gz'))):
        print('Processing %s...' % csv_gz_path)
        csv_path = csv_gz_path.replace('.gz', '')
        csv_file = open(csv_path, 'w')
        gunzip = subprocess.Popen(['gunzip', '-c', csv_gz_path], stdout=csv_file)
        gunzip.wait()
        csv_file.close()
        sqlite3 = subprocess.Popen(['sqlite3', sqlite3_path], stdin=subprocess.PIPE)
        sqlite3.communicate('.mode csv\n.import {} {}\n'.format(csv_path, table))
        sqlite3.wait()
        os.remove(csv_path)
