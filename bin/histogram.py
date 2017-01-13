#!/usr/bin/env python3

import glob, sqlite3, sys

import matplotlib.pyplot as pp
import numpy as np

query = "SELECT COUNT(*) FROM `task_usage` GROUP BY `job ID`, `task index`"

def main(data_path):
    count = 0
    data = []
    pp.figure(facecolor='w', edgecolor='k')
    path_pattern = "{}/**/*.sqlite3".format(data_path)
    for part_path in glob.glob(path_pattern, recursive=True):
        connection = sqlite3.connect(part_path)
        cursor = connection.cursor()
        cursor.execute(query)
        data = np.append(data, np.array([row[0] for row in cursor]))
        connection.close()
        count += 1
        if count % 1000 == 0:
            pp.clf()
            pp.title("Processed {}".format(count))
            pp.hist(data[data < 200], bins=200)
            pp.pause(1e-3)
    pp.show()

if __name__ == '__main__':
    if len(sys.argv) != 2:
        raise Exception('expected an argument')
    main(sys.argv[1])
