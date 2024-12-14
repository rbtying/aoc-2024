#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>

#define max_x 101
#define max_y 103

int main() {
    char line[1024];
    int px[1024] = {0}, py[1024] = {0}, vx[1024] = {0}, vy[1024] = {0};
    int grid[max_y][max_x] = {{0}};

    int n = 0;
    FILE* f = fopen("../../input/2024/day14.txt", "r");

    while (fgets(line, sizeof line, f) != NULL) {
        if (!*line) {
            continue;
        }
        if (sscanf(line, "p=%d,%d v=%d,%d", &px[n], &py[n], &vx[n], &vy[n]) != 4) {
            return 1;
        }
        n++;
    }

    for (int s = 1; ; s++) {
        for (int i = 0; i < n; i++) {
            px[i] = ((px[i] + vx[i]) % max_x + max_x) % max_x;
            py[i] = ((py[i] + vy[i]) % max_y + max_y) % max_y;
        }

        if (s == 100) {
            int q1 = 0, q2 = 0, q3 = 0, q4 = 0;
            int mid_x = max_x / 2;
            int mid_y = max_y / 2;

            for (int i = 0; i < n; i++) {
                if (px[i] < mid_x && py[i] < mid_y) {
                    q1++;
                }
                if (px[i] >= max_x - mid_x && py[i] < mid_y) {
                    q2++;
                }
                if (px[i] >= max_x - mid_x && py[i] >= max_y - mid_y) {
                    q4++;
                }
                if (px[i] < mid_x && py[i] >= max_y - mid_y) {
                    q3++;
                }
            }
            printf("part 1: %d\n", q1 * q2 * q3 * q4);
        }

        int found_tree = 1;

        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                if (i != j && px[i] == px[j] && py[i] == py[j]) {
                    found_tree = 0;
                    break;
                }
            }
            if (!found_tree) {
                break;
            }
        }
        if (s < 101) {
            found_tree = 0;
        }

        if (found_tree) {
            memset(grid, 0, sizeof(int) * 103 * 101);
            for (int i = 0; i < n; i++) {
                grid[py[i]][px[i]] += 1;
            }

            for (int r = 0; r < 103; r++) {
                for (int c = 0; c < 101; c++) {
                    if (grid[r][c]) {
                        printf("%d", grid[r][c]);
                    } else {
                        printf(".");
                    }
                }
                printf("\n");
            }
            printf("Part 2: %d\n", s);
            return 0;
        }
    }

    return 0;
}