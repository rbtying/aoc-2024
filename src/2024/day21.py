from aoc import *
import itertools
import heapq
from collections import defaultdict, Counter, deque
import functools
import re
from dataclasses import dataclass

KEYPAD=r"""789
456
123
 0A"""
DIRKEYPAD = r""" ^A
<v>"""
keypad = CharGrid(KEYPAD)
revkeypad = {v: k for (k, v) in keypad.dense_iter()}
dirkeypad = CharGrid(DIRKEYPAD)
revdirkeypad = {v: k for (k, v) in dirkeypad.dense_iter()}

@functools.cache
def h(c, n, nr, isdir=True):
    q = deque()
    if isdir:
        q.append((revdirkeypad[c], ""))
    else:
        q.append((revkeypad[c], ""))
    ans = float('inf')
    if isdir:
        np = revdirkeypad[n]
    else:
        np = revkeypad[n]
    while q:
        l, p = q.pop()
        if l == np:
            v = g(p + "A", nr - 1)
            ans = min(ans, v)
            continue
        # skip the gap
        if isdir:
            if dirkeypad[l] == ' ':
                continue
        else:
            if keypad[l] == ' ':
                continue
        d = np - l
        r = project_row_norm(d)
        c = project_col_norm(d)
        if r:
            q.append((l + r, p + complex_to_ascii(r)))
        if c:
            q.append((l + c, p + complex_to_ascii(c)))
    return ans

@functools.cache
def g(p, n):
    if n == 1:
        return len(p)
    
    res = 0
    pos = 'A'
    for b in p:
        res += h(pos, b, n, True)
        pos = b
    return res

def part1(s, nr=3):
    total = 0
    for code in s.splitlines():
        curr = 'A'
        res = 0
        for n in code:
            res += h(curr, n, nr + 1, False)
            curr = n
        total += res * int(code[:-1])

    return total

def part2(s):
    return part1(s, nr=26)

EXAMPLE = r"""029A
980A
179A
456A
379A"""
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