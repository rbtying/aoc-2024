#!/bin/bash

awk '{for (i = 1; i <= NF; i++) {print($i " 1")}}' ../../input/2024/day11.txt > /tmp/a

for i in {1..25}
do
  echo "loop $i"

  awk '
  {
    if ($1 == 0) {
      print 1, $2
    } else if (length($1) %2 == 0) {
      print int(substr($1, 1, length($1) / 2)), $2
      print int(substr($1, length($1) / 2 + 1, length($1) / 2)), $2
    } else {
      print $1 * 2024, $2
    }
  }
  ' /tmp/a | awk '{a[$1] += $2} END {for (i in a) print i, a[i]}' > /tmp/b
  mv /tmp/b /tmp/a
done
awk 'BEGIN {a = 0} {a += $2} END {print a}' /tmp/a

for i in {26..75}
do
  echo "loop $i"

  awk '
  {
    if ($1 == 0) {
      print 1, $2
    } else if (length($1) %2 == 0) {
      print int(substr($1, 1, length($1) / 2)), $2
      print int(substr($1, length($1) / 2 + 1, length($1) / 2)), $2
    } else {
      print $1 * 2024, $2
    }
  }
  ' /tmp/a | awk '{a[$1] += $2} END {for (i in a) print i, a[i]}' > /tmp/b
  mv /tmp/b /tmp/a
done
awk 'BEGIN {a = 0} {a += $2} END {print a}' /tmp/a
