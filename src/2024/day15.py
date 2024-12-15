from aoc import *
import itertools
import heapq
from collections import defaultdict, Counter
import functools
import re

DIRMAP = {
    '^': CharGrid.UP,
    '>': CharGrid.RIGHT,
    '<': CharGrid.LEFT,
    'v': CharGrid.DOWN
}

def part1(s: str):
    ms, ds = s.split("\n\n")
    grid = CharGrid(ms)

    start_loc = None
    for loc, v in grid.dense_iter():
        if v == '@':
            grid[loc] = '.'
            start_loc = loc
            break
    
    loc = start_loc
    for x in ds:
        dir = DIRMAP.get(x)
        if not dir:
            continue
        next_loc = loc + dir
        if grid[next_loc] == '.':
            loc = next_loc
        elif grid[next_loc] == 'O':
            box_loc = next_loc
            movable = True
            while True:
                if grid[box_loc] == 'O':
                    box_loc += dir
                elif grid[box_loc] == '#':
                    movable = False
                    break
                elif grid[box_loc] == '.':
                    break
            if movable:
                grid[next_loc] = '.'
                grid[box_loc] = 'O'
                loc = next_loc
        elif grid[next_loc] == '#':
            continue
    r = 0
    for loc, v in grid.dense_iter():
        if v == 'O':
            r += loc.real * 100 + loc.imag
    return r




def part2(s: str):
    ms, ds = s.split("\n\n")
    grid = CharGrid(ms)

    boxes = set()
    walls = set()
    start_loc = None
    for r in range(grid.min_r, grid.max_r + 1):
        for c in range(grid.min_c, grid.max_c + 1):
            v = grid[complex(r, c)]
            if v == '@':
                start_loc = complex(r, c * 2)
            elif v == 'O':
                boxes.add(complex(r, c * 2))
            elif v == '#':
                walls.add(complex(r, c * 2))
                walls.add(complex(r, c * 2 + 1))
    
    loc = start_loc

    def attempt_push(box, dir):
        n = box + dir
        if n in walls or n + CharGrid.RIGHT in walls:
            return False
        if dir in (CharGrid.UP, CharGrid.DOWN):
            for nn in (n, n + CharGrid.LEFT, n + CharGrid.RIGHT):
                if nn in boxes:
                    r = attempt_push(nn, dir)
                    if not r:
                        return r
        else:
            if n + dir in boxes:
                r = attempt_push(n + dir, dir)
                if not r:
                    return r
        boxes.remove(box)
        boxes.add(n)
        return True
                

    for x in ds:
        dir = DIRMAP.get(x)
        if not dir:
            continue
        next_loc = loc + dir

        for box in boxes:
            assert box not in walls
            assert box + CharGrid.RIGHT not in boxes
            assert box + CharGrid.RIGHT not in walls

        if next_loc in walls:
            continue

        # the boxes are always the `[`, so to check collision against the `]` we need to shift everything left by 1
        # []
        #  ^
        bail = False
        for nn in (next_loc, next_loc + CharGrid.LEFT):
            if nn in boxes:
                copy = {x for x in boxes}
                if not attempt_push(nn, dir):
                    boxes = copy
                    bail = True
                    continue
        if not bail:
            loc = next_loc

    r = 0
    for loc in boxes:
        r += loc.real * 100 + loc.imag
    return r

EXAMPLE = r"""########
#..O.O.#
##@.O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

<^^>>>vv<v>>v<<"""
EXAMPLE2 = r"""#######
#...#.#
#.....#
#..OO@#
#..O..#
#.....#
#######

<vv<<^^<<^^"""
EXAMPLE2 = r"""##########
#..O..O.O#
#......O.#
#.OO..O.O#
#..O@..O.#
#O#..O...#
#O..O..O.#
#.OO.O.OO#
#....O...#
##########

<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^"""

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