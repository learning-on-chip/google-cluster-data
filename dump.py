#!/usr/bin/env python

import glob, os, sqlite3, sys

sys.path.append(os.path.abspath("csv2sqlite"))
import csv2sqlite

setup_sql = {
    "job_events": """
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

    "task_events": """
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

    "task_usage": """
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

def fail(message):
    print(message)
    sys.exit(1)

def setup_sqlite(table):
    filename = 'google.sqlite3'
    connection = sqlite3.connect(filename)
    cursor = connection.cursor()
    for sql in setup_sql[table].split(';'):
        cursor.execute(sql)
    connection.commit()
    connection.close()
    return filename

def find_parts(table):
    return sorted(glob.glob(os.path.join(table, '*.csv.gz')))

for table in sys.argv[1:]:
    sqlite = setup_sqlite(table)
    headers = 'headers/%s.csv' % table
    types = 'types/%s.csv' % table
    for csv in find_parts(table):
        print('Processing %s...' % csv)
        csv2sqlite.convert(csv, sqlite, table, headers, 'gzip', types)
