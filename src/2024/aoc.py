from typing import Iterable, List, Dict, Union, TypeVar, Generator, Set
from collections import deque, defaultdict
from dataclasses import dataclass
import re

T = TypeVar("T")

def ints(s: str) -> Iterable[int]:
    return list(map(int, re.findall("(\-?\d+)", s)))

def sign(s: Union[float, int]) -> int:
    if s < 0:
        return -1
    elif s > 0:
        return 1
    return 0

def windows(l: Iterable[T], n: int) -> Generator[List[T], None, None]:
    d = deque()

    for v in l:
        d.append(v)
        if len(d) > n:
            d.popleft()
        if len(d) == n:
            yield list(d)

    yield list(d)


class CharGrid:
    DOWN = 1
    UP = -1
    LEFT = -1j
    RIGHT = 1j
    DOWN_LEFT = DOWN + LEFT
    DOWN_RIGHT = DOWN + RIGHT
    UP_LEFT = UP + LEFT
    UP_RIGHT = UP + RIGHT
    FOURWAY = [UP, DOWN, LEFT, RIGHT]
    EIGHTWAY = [UP, DOWN, LEFT, RIGHT, DOWN_LEFT, DOWN_RIGHT, UP_LEFT, UP_RIGHT]

    def __init__(self, chargrid: str):
        self.grid = defaultdict(lambda: None)
        self.max_r = 0
        self.max_c = 0
        self.min_r = 0
        self.min_c = 0
        for (r, line) in enumerate(chargrid.splitlines()):
            for (c, v) in enumerate(line):
                self.grid[complex(r, c)] = v
                self.max_c = max(c, self.max_c)
                self.min_c = min(c, self.min_c)
            self.min_r = min(r, self.min_r)
            self.max_r = max(r, self.max_r)
    
    def points(self):
        return sorted(self.grid.keys())
    
    def dense_iter(self):
        for r in range(self.min_r, self.max_r + 1):
            for c in range(self.min_c, self.max_c + 1):
                l = complex(r, c)
                yield l, self.grid[l]

    def __getitem__(self, key):
        if isinstance(key, tuple):
            key = complex(*key)
        if not isinstance(key, complex):
            raise RuntimeError("invalid key " + key)
        return self.grid[key]

    def __setitem__(self, key, value):
        if isinstance(key, tuple):
            key = complex(*key)
        if not isinstance(key, complex):
            raise RuntimeError("invalid key " + key)
        self.max_r = max(self.max_r, int(key.real))
        self.min_r = min(self.min_r, int(key.real))
        self.max_c = max(self.max_c, int(key.imag))
        self.min_c = min(self.min_c, int(key.imag))
        self.grid[key] = value
    
    def __str__(self):
        p = ""
        for r in range(self.min_r, self.max_r + 1):
            for c in range(self.min_c, self.max_c + 1):
                v = self.grid[complex(r, c)]
                if v is not None:
                    p += v
                else:
                    p += ' '
            p += "\n"
        return p

def toposort(vertices: Iterable[T], deps: Dict[T, Set[T]]):
    all_vertices = set(vertices)
    filtered_deps = {k: all_vertices.intersection(deps.get(k, set())) for k in all_vertices}
    indegree = {k: 0 for k in all_vertices}
    for v in filtered_deps.values():
        for vv in v:
            indegree[vv] += 1

    ordered = []

    q = deque(k for k in all_vertices if indegree[k] == 0)
    while q:
        n = q.popleft()
        ordered.append(n)

        for nn in filtered_deps[n]:
            indegree[nn] -= 1
            if indegree[nn] == 0:
                q.append(nn)

    return ordered

def rotate_left_2d(a: complex) -> complex:
    return complex(-a.imag, a.real)

def rotate_right_2d(a: complex) -> complex:
    return complex(a.imag, -a.real)
