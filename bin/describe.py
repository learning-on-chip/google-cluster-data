#!/usr/bin/env python3

import sys

def describe(name):
    if name == 'job_events':
        return [
            '`time` INTEGER NOT NULL',
            '`missing info` INTEGER',
            '`job ID` INTEGER NOT NULL',
            '`event type` INTEGER NOT NULL',
            '`user` TEXT',
            '`scheduling class` INTEGER',
            '`job name` TEXT',
            '`logical job name` TEXT',
        ]
    elif name == 'task_events':
        return [
            '`time` INTEGER NOT NULL',
            '`missing info` INTEGER',
            '`job ID` INTEGER NOT NULL',
            '`task index` INTEGER NOT NULL',
            '`machine ID` INTEGER',
            '`event type` INTEGER NOT NULL',
            '`user` TEXT',
            '`scheduling class` INTEGER',
            '`priority` INTEGER NOT NULL',
            '`CPU request` REAL',
            '`memory request` REAL',
            '`disk space request` REAL',
            '`different machines restriction` INTEGER',
        ]
    elif name == 'task_usage':
        return [
            '`start time` INTEGER NOT NULL',
            '`end time` INTEGER NOT NULL',
            '`job ID` INTEGER NOT NULL',
            '`task index` INTEGER NOT NULL',
            '`machine ID` INTEGER NOT NULL',
            '`CPU rate` REAL',
            '`canonical memory usage` REAL',
            '`assigned memory usage` REAL',
            '`unmapped page cache` REAL',
            '`total page cache` REAL',
            '`maximum memory usage` REAL',
            '`disk IO time` REAL',
            '`local disk space usage` REAL',
            '`maximum CPU rate` REAL',
            '`maximum disk IO time` REAL',
            '`cycles per instruction` REAL',
            '`memory accesses per instruction` REAL',
            '`sample portion` REAL',
            '`aggregation type` INTEGER',
            '`sampled CPU usage` REAL',
        ]
    raise Exception('the table is unknown')

if __name__ == '__main__':
    if len(sys.argv) != 2:
        raise Exception('expected an argument')
    for line in describe(sys.argv[1]):
        print(line)
