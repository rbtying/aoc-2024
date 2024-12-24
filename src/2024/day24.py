from aoc import *
import itertools
import heapq
from collections import defaultdict, Counter, deque
import functools
import re
from dataclasses import dataclass

def part1(s):
    vars_vals, gates_s = s.split("\n\n")

    registers = defaultdict(None)
    gates = {}

    for line in vars_vals.splitlines():
        n, v = line.split(": ")
        registers[n] = v == '1'

    zs = []
    for line in gates_s.splitlines():
        lhs, rhs = line.split(" -> ")
        a, e, b = lhs.split(" ")
        gates[rhs] = (e, a, b)
        if rhs.startswith("z"):
            zs.append(rhs)

    def solve(x):
        if x not in registers:
            e, a, b = gates[x]

            if e == 'AND':
                return solve(a) and solve(b)
            elif e == 'OR':
                return solve(a) or solve(b)
            elif e == 'XOR':
                return solve(a) ^ solve(b)
            else:
                assert False
        else:
            return registers[x]


    for z in sorted(zs):
        registers[z] = solve(z)

    return sum(registers[v] << i for i, v in enumerate(sorted(zs)))
    

def part2(s):
    vars_vals, gates_s = s.split("\n\n")

    registers = defaultdict(None)
    gates = {}

    for line in vars_vals.splitlines():
        n, v = line.split(": ")
        registers[n] = v == '1'

    x_val = sum(registers[v] << i for (i, v) in enumerate(sorted(k for k in registers if k.startswith("x"))))
    y_val = sum(registers[v] << i for (i, v) in enumerate(sorted(k for k in registers if k.startswith("y"))))

    zs = []

    for line in gates_s.splitlines():
        lhs, rhs = line.split(" -> ")
        a, e, b = lhs.split(" ")
        gates[rhs] = (e, a, b)
        if rhs.startswith("z"):
            zs.append(rhs)

    def swap(a, b):
        t = gates[a]
        gates[a] = gates[b]
        gates[b] = t

    # z = XOR
    #     (x AND y) OR ((x XOR y) AND (OR from prior bit))
    #     (x XOR y)

    pairs = [
        ["z06", "hwk"],
        ["tnt", "qmd"],
        ["z31", "hpc"],
        ["z37", "cgr"],
    ]

    for p in pairs:
        swap(*p)

    # print("digraph {")
    # for k, (e, a, b) in gates.items():
    #     print(f"{a} -> {k}")
    #     print(f"{b} -> {k}")
    #     print(f"{k} [label=\"{k} {e}\"]")
    # print("}")
    

    intended_z = x_val + y_val

    def solve(x):
        if x not in registers:
            e, a, b = gates[x]

            if e == 'AND':
                return solve(a) and solve(b)
            elif e == 'OR':
                return solve(a) or solve(b)
            elif e == 'XOR':
                return solve(a) ^ solve(b)
            else:
                assert False
        else:
            return registers[x]

    for z in sorted(zs):
        registers[z] = solve(z)

    for i, v in enumerate(sorted(zs)):
        if registers[v] << i != intended_z & 1 << i:
            print(gates[v])
            print(i, v, registers[v], bool(intended_z & 1 << i), bool(x_val & 1 << i), bool(y_val & 1 << i))

    return ",".join(sorted(itertools.chain(*pairs)))


EXAMPLE = r"""x00: 1
x01: 1
x02: 1
y00: 0
y01: 1
y02: 0

x00 AND y00 -> z00
x01 XOR y01 -> z01
x02 OR y02 -> z02"""
EXAMPLE2 = r"""x00: 0
x01: 1
x02: 0
x03: 1
x04: 0
x05: 1
y00: 0
y01: 0
y02: 1
y03: 1
y04: 0
y05: 1

x00 AND y00 -> z05
x01 AND y01 -> z02
x02 AND y02 -> z01
x03 AND y03 -> z03
x04 AND y04 -> z04
x05 AND y05 -> z00"""

if __name__ == '__main__':
    # print(part1(EXAMPLE))
    # print(part2(EXAMPLE2))

    import os
    import pathlib
    p = pathlib.Path(os.path.abspath(__file__))
    input_str = open(os.path.join(p.parent.parent.parent, "input", "2024", p.stem + ".txt")).read()

    import time
    time.sleep(1)

    # print(part1(input_str.strip()))
    print(part2(input_str.strip()))