const std = @import("std");
const mem = std.mem;
const aoclib = @import("aoclib");

input: []const u8,
allocator: mem.Allocator,

pub fn part1(this: *const @This()) !?i64 {
    var grid = try aoclib.Grid2D.init(this.allocator, this.input);
    defer grid.deinit();

    var loc = grid.min_bounds;
    var num_matches: i64 = 0;

    while (loc.r <= grid.max_bounds.r) {
        loc.c = 0;
        while (loc.c <= grid.max_bounds.c) {
            if (grid.get(loc) == 'X') {
                for (aoclib.EIGHT_WAY) |dir| {
                    var match = true;
                    for ("XMAS", 0..) |v, b| {
                        if (grid.get(loc.add(dir.scalar_mul(@as(i64, @intCast(b))))) != v) {
                            match = false;
                        }
                    }
                    if (match) {
                        num_matches += 1;
                    }
                }
            }
            loc.c += 1;
        }
        loc.r += 1;
    }

    return num_matches;
}

pub fn part2(this: *const @This()) !?i64 {
    var grid = try aoclib.Grid2D.init(this.allocator, this.input);
    defer grid.deinit();

    var loc = grid.min_bounds;
    var num_matches: i64 = 0;

    while (loc.r <= grid.max_bounds.r) {
        loc.c = 0;
        while (loc.c <= grid.max_bounds.c) {
            if (grid.get(loc) == 'A') {
                var ct: usize = 0;
                for ([_]aoclib.P2D(i64){ aoclib.UP_LEFT, aoclib.DOWN_LEFT }, [_]aoclib.P2D(i64){ aoclib.DOWN_RIGHT, aoclib.UP_RIGHT }) |diag1, diag2| {
                    const a = grid.get(loc.add(diag1));
                    const b = grid.get(loc.add(diag2));
                    if ((a == 'M' and b == 'S') or (a == 'S' and b == 'M')) {
                        ct += 1;
                    }
                }
                if (ct == 2) {
                    num_matches += 1;
                }
            }
            loc.c += 1;
        }
        loc.r += 1;
    }

    return num_matches;
}

test "it should do nothing" {
    const allocator = std.testing.allocator;
    const input = "";

    const problem: @This() = .{
        .input = input,
        .allocator = allocator,
    };

    try std.testing.expectEqual(null, try problem.part1());
    try std.testing.expectEqual(null, try problem.part2());
}
