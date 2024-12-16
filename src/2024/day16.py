from aoc import *
import itertools
import heapq
from collections import defaultdict, Counter
import functools
import re
from dataclasses import dataclass

def solve(s: str):
    grid = CharGrid(s)
    start_tile = None
    end_tile = None
    for loc, v in grid.dense_iter():
        if v == 'S':
            start_tile = loc
        elif v == 'E':
            end_tile = loc
    
    dist = defaultdict(lambda: float('inf'))
    dist[(start_tile, CharGrid.RIGHT)] = 0
    prev = defaultdict(set)
    visited = set()
    q = []

    @dataclass
    class Q: 
        dist: int
        loc: complex
        dir: complex

        def __lt__(self, other):
            return self.dist < other.dist

    heapq.heappush(q, Q(0, start_tile, CharGrid.RIGHT))
    while q:
        n = heapq.heappop(q)
        if (n.loc, n.dir) in visited:
            continue

        visited.add((n.loc, n.dir))

        for neighbor in ((n.loc + n.dir, n.dir, 1), (n.loc, rotate_right_2d(n.dir), 1000), (n.loc, rotate_left_2d(n.dir), 1000)):
            l, d, c = neighbor
            if grid[l] == '#':
                continue
            if (l, d) not in visited:
                old_cost = dist[(l, d)]
                new_cost = dist[(n.loc, n.dir)] + c
                if new_cost < old_cost:
                    heapq.heappush(q, Q(new_cost, l, d))
                    dist[(l, d)] = new_cost
                    prev[(l, d)] = {(n.loc, n.dir)}
                elif new_cost == old_cost:
                    prev[(l, d)].add((n.loc, n.dir))
    seats = set()
    stk = [k for k in dist.keys() if k[0] == end_tile]
    while stk:
        n = stk.pop()
        grid[n[0]] = 'O'
        seats.add(n[0])
        if n[0] != start_tile:
            stk.extend(prev[n])

    return len(seats), min(v for (l, _), v in dist.items() if l == end_tile)

def part1(s: str):
    return solve(s)[1]

def part2(s: str):
    return solve(s)[0]

EXAMPLE = r"""###############
#.......#....E#
#.#.###.#.###.#
#.....#.#...#.#
#.###.#####.#.#
#.#.#.......#.#
#.#.#####.###.#
#...........#.#
###.#.#####.#.#
#...#.....#.#.#
#.#.#.###.#.#.#
#.....#...#.#.#
#.###.#.#.#.#.#
#S..#.....#...#
###############"""
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

    print(part1(input_str.strip()))
    print(part2(input_str.strip()))
