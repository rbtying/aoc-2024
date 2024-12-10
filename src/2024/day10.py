from aoc import *
import itertools
import heapq

def part1(s: str):
    grid = CharGrid(s)

    trailheads = []
    summits = set()
    for pos, v in grid.dense_iter():
        if v == '0':
            trailheads.append(pos)
        elif v == '9':
            summits.add(pos)

    succ = {
        str(k): str(k + 1)
        for k in range(0, 9)
    }
    
    results = {}

    for th in trailheads:
        s = set()
        visited = set()
        stk = [th]

        while stk:
            n = stk.pop()
            visited.add(n)

            v = grid[n]
            if v == '9':
                s.add(n)
                continue

            for d in CharGrid.FOURWAY:
                a = n + d
                if grid[a] == succ[v] and not a in visited:
                    stk.append(a)
        results[th] = len(s)
    return sum(results.values())

def part2(s: str):
    grid = CharGrid(s)

    trailheads = []
    summits = set()
    for pos, v in grid.dense_iter():
        if v == '0':
            trailheads.append(pos)
        elif v == '9':
            summits.add(pos)

    succ = {
        str(k): str(k + 1)
        for k in range(0, 9)
    }
    
    results = {}

    for th in trailheads:
        s = set()
        stk = [[th]]

        while stk:
            path = stk.pop()

            v = grid[path[-1]]
            if v == '9':
                s.add(tuple(path))
                continue

            for d in CharGrid.FOURWAY:
                a = path[-1] + d
                if grid[a] == succ[v]:
                    stk.append(path + [a])
        results[th] = len(s)
    return sum(results.values())

EXAMPLE = r"""89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732"""
EXAMPLE2 = EXAMPLE

if __name__ == '__main__':
    print(part1(EXAMPLE))
    print(part2(EXAMPLE2))

    import os
    import pathlib
    p = pathlib.Path(os.path.abspath(__file__))
    input_str = open(os.path.join(p.parent.parent.parent, "input", "2024", p.stem + ".txt")).read()

    import time
    time.sleep(1)

    print(part1(input_str))
    print(part2(input_str))
