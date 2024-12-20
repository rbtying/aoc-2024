const std = @import("std");
const mem = std.mem;
const aoclib = @import("aoclib");

input: []const u8,
allocator: mem.Allocator,

pub fn solve(this: *const @This(), max: usize) !?i64 {
    var grid = try aoclib.Grid2D.init(this.allocator, this.input);
    defer grid.deinit();

    var iter = grid.denseIterator();
    while (iter.next()) |v| {
        if (v.value == 'S') {
            var path = std.ArrayList(aoclib.P2D(i64)).init(this.allocator);
            defer path.deinit();

            var n = v.loc;
            while (true) {
                try path.append(n);
                if (grid.get(n) == 'E') {
                    break;
                }
                for (aoclib.FOUR_WAY) |d| {
                    if (path.items.len >= 2) {
                        const prevDir = path.items[path.items.len - 2].sub(path.items[path.items.len - 1]);
                        if (prevDir.eql(d)) {
                            continue;
                        }
                    }
                    const n2 = n.add(d);
                    if (grid.get(n2) == '.' or grid.get(n2) == 'E') {
                        n = n2;
                        break;
                    }
                }
            }

            var shortcuts = std.AutoHashMap([2]usize, bool).init(this.allocator);
            defer shortcuts.deinit();

            for (path.items, 0..) |p, idx| {
                for (path.items[idx + 1 ..], 1..) |p2, d| {
                    const del = p2.sub(p);
                    const m = @abs(del.r) + @abs(del.c);
                    if (m <= max and d - m >= 100) {
                        try shortcuts.put([2]usize{ idx, d }, true);
                    }
                }
            }
            return shortcuts.count();
        }
    }
    return null;
}

pub fn part1(this: *const @This()) !?i64 {
    return solve(this, 2);
}

pub fn part2(this: *const @This()) !?i64 {
    return solve(this, 20);
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
