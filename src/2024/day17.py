from aoc import *
import itertools
import heapq
from collections import defaultdict, Counter
import functools
import re
from dataclasses import dataclass


def part1(s: str):
    registers, program = s.split("\n\n")
    a, b, c = ints(registers)
    prog = ints(program)

    instruction_ptr = 0
    outputs = []

    while True:
        if instruction_ptr >= len(prog):
            break
        op = prog[instruction_ptr]
        instruction_ptr += 1
        arg = prog[instruction_ptr]
        if instruction_ptr >= len(prog):
            break
        instruction_ptr += 1


        arg_combo = 7
        if arg <= 3:
            arg_combo = arg
        elif arg == 4:
            arg_combo = a
        elif arg == 5:
            arg_combo = b
        elif arg == 6:
            arg_combo = c

        if op == 0:
            denom = pow(2, arg_combo)
            a = a // denom
        elif op == 1:
            b = b ^ arg
        elif op == 2:
            b = arg_combo % 8
        elif op == 3:
            if a != 0:
                instruction_ptr = arg
                if instruction_ptr >= len(prog):
                    break
        elif op == 4:
            b = b ^ c
        elif op == 5:
            outputs.append(arg_combo % 8)
        elif op == 6:
            denom = pow(2, arg_combo)
            b = a // denom
        elif op == 7:
            denom = pow(2, arg_combo)
            c = a // denom

    return ",".join(map(str, outputs))

def part2(s: str):
    _, program = s.split("\n\n")
    prog = ints(program)

    # Do an exhaustive search for viable values for register a after staring at
    # the input
    # a always right-shifts by 3 bits, and outputs the value of b
    # the value of b is ((a % 8) ^ 5) ^ 6 ^ (a // 2^((a % 8) ^ 5))
    # unfortunately this is not super clean so we have to exhaustively search

    candidates = [0]
    for v in reversed(prog):
        target = v
        new_candidates = []
        for candidate in candidates:
            # we're only searching for 3 bits at a time and narrowing the field
            # from there
            rmin = max(1, candidate * 8)
            rmax = candidate * 8 + 7
            for possible in range(rmin, rmax + 1):
                rb = possible % 8
                rc = possible // (2 ** (rb ^ prog[5]))
                # hard-code the equality check based on the above
                if (target ^ rc ^ prog[3] ^ prog[7]) % 8 == possible % 8:
                    # there will be multiple :cry:
                    new_candidates.append((candidate * 8) + rb)
        candidates = new_candidates
    return min(candidates)

EXAMPLE = r"""Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0"""
EXAMPLE2 = r"""Register A: 2024
Register B: 0
Register C: 0

Program: 0,3,5,4,3,0"""

if __name__ == '__main__':
    print(part1(EXAMPLE))

    import os
    import pathlib
    p = pathlib.Path(os.path.abspath(__file__))
    input_str = open(os.path.join(p.parent.parent.parent, "input", "2024", p.stem + ".txt")).read()

    import time
    time.sleep(1)

    print(part1(input_str.strip()))
    print(part2(input_str.strip()))