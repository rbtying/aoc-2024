from aoc import *
import itertools
import heapq
from collections import defaultdict, Counter, deque
import functools
import re
from dataclasses import dataclass

def part1(s):
    locks = []
    keys = []
    for lock_or_key in s.split("\n\n"):
        is_lock = lock_or_key[0] == '#'

        if is_lock:
            iter = lock_or_key.splitlines()
        else:
            iter = reversed(lock_or_key.splitlines())

        val = [0, 0, 0, 0, 0]
        for r, line in enumerate(iter):
            for c, v in enumerate(line):
                if v == '#':
                    val[c] = r
        
        if is_lock:
            locks.append(val)
        else:
            keys.append(val)

    ct = 0
    for l in locks:
        for k in keys:
            if all(l[i] + k[i] <= 5 for i in range(5)):
                ct += 1
    return ct


EXAMPLE = r"""#####
.####
.####
.####
.#.#.
.#...
.....

#####
##.##
.#.##
...##
...#.
...#.
.....

.....
#....
#....
#...#
#.#.#
#.###
#####

.....
.....
#.#..
###..
###.#
###.#
#####

.....
.....
.....
#....
#.#..
#.#.#
#####"""
EXAMPLE2 = EXAMPLE
if __name__ == '__main__':
    print(part1(EXAMPLE))

    import os
    import pathlib
    p = pathlib.Path(os.path.abspath(__file__))
    input_str = open(os.path.join(p.parent.parent.parent, "input", "2024", p.stem + ".txt")).read()

    import time
    time.sleep(1)

    print(part1(input_str.strip()))