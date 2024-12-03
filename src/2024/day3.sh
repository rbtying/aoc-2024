#!/bin/bash
EXAMPLE="xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"
EXAMPLE2="xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"
REGEX='(mul\(([0-9]+),([0-9]+)\))|(don'\''t\(\))|(do\(\))'
AWK='match($0, /'$REGEX'/, m) { if (m[4] != "") {d=1}; if (m[5] != "") {d=0}; if (!d) { s += m[2] * m[3] }} END {print s}'
echo $EXAMPLE | grep -oP $REGEX | gawk "$AWK"
echo $EXAMPLE2 | grep -oP $REGEX | gawk "$AWK"
< input/2024/day3.txt grep -oP $REGEX | gawk "$AWK"