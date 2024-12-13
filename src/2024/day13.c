#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main() {
    char line[1024];
    int line_num = 0;
    long total = 0;
    long total2 = 0;
    double ax, ay, bx, by, tx, ty, a, b;
    const double offset = 10000000000000;

    FILE* f = fopen("../../input/2024/day13.txt", "r");

    while (fgets(line, sizeof line, f) != NULL) {
        if (line_num % 4 == 0) {
            if (sscanf(line, "Button A: X+%lf, Y+%lf", &ax, &ay) != 2) {
                return 1;
            }
        } else if (line_num % 4 == 1) {
            if (sscanf(line, "Button B: X+%lf, Y+%lf", &bx, &by) != 2) {
                return 1;
            }
        } else if (line_num % 4 == 2) {
            if (sscanf(line, "Prize: X=%lf, Y=%lf", &tx, &ty) != 2) {
                return 1;
            }

            a = (tx * by - ty * bx) / (ax * by - ay * bx);
            b = (ty - ay * a) / by;

            if (a == (long) a && b == (long) b) {
                total += 3 * (long) a + (long) b;
            }
            tx += offset;
            ty += offset;

            a = (tx * by - ty * bx) / (ax * by - ay * bx);
            b = (ty - ay * a) / by;

            if (a == (long) a && b == (long) b) {
                total2 += 3 * (long) a + (long) b;
            }
        }
        line_num++;
    }

    printf("part 1: %ld\n", total);
    printf("part 2: %ld\n", total2);

    return 0;
}