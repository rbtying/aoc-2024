from aoc import *
import itertools
import heapq
from collections import defaultdict

def part1(s: str):
    grid = CharGrid(s)

    area = defaultdict(int)
    perimeter = defaultdict(int)

    components = {}

    for loc, v in grid.dense_iter():
        if loc in components:
            continue
        stk = [loc]
        while stk:
            n = stk.pop()
            if n in components:
                continue
            area[(v, loc)] += 1
            components[n] = loc

            for d in CharGrid.FOURWAY:
                nn = n + d
                if grid[nn] != v:
                    perimeter[(v, loc)] += 1
                elif nn not in components:
                    stk.append(nn)

    return sum(perimeter[k] * area[k] for k in area.keys())

def part2(s: str):
    grid = CharGrid(s)

    area = defaultdict(int)

    components = {}

    for loc, v in grid.dense_iter():
        if loc in components:
            continue
        stk = [loc]
        while stk:
            n = stk.pop()
            if n in components:
                continue
            area[(v, loc)] += 1
            components[n] = loc

            for d in CharGrid.FOURWAY:
                nn = n + d
                if grid[nn] == v and nn not in components:
                    stk.append(nn)
    
    corners = defaultdict(int)
    for loc, v in grid.dense_iter():
        center = components[loc]
        for d in (CharGrid.UP_LEFT, CharGrid.UP_RIGHT, CharGrid.DOWN_LEFT, CharGrid.DOWN_RIGHT):
            row = components.get(loc + d.real)
            col = components.get(loc + d.imag * 1j)
            diag = components.get(loc + d)
            if (center != row and center != col) or (center == row and center == col and center != diag):
                corners[center] += 1

    return sum(corners[k[1]] * area[k] for k in area.keys())

EXAMPLE = r"""AAAA
BBCD
BBCC
EEEC"""
EXAMPLE2 = r"""RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE"""

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