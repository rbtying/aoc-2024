const std = @import("std");
const mem = std.mem;
const aoclib = @import("aoclib");

input: []const u8,
allocator: mem.Allocator,

const I = struct {
    p: aoclib.P2D(i64),
    c: u32,
};

fn order(_: void, a: I, b: I) std.math.Order {
    return std.math.order(a.c, b.c);
}

fn shortestPath(corrupted: *std.AutoHashMap(aoclib.P2D(i64), bool), allocator: std.mem.Allocator) !?i64 {
    var q = std.PriorityQueue(I, void, order).init(allocator, {});
    defer q.deinit();

    var dist = std.AutoHashMap(aoclib.P2D(i64), u64).init(allocator);
    defer dist.deinit();
    var visited = std.AutoHashMap(aoclib.P2D(i64), bool).init(allocator);
    defer visited.deinit();

    try dist.put(.{ .r = 0, .c = 0 }, 0);
    try q.add(.{ .p = .{ .r = 0, .c = 0 }, .c = 0 });

    while (q.removeOrNull()) |n| {
        if (n.p.r == 70 and n.p.c == 70) {
            return n.c;
        }
        if (visited.contains(n.p)) {
            continue;
        }
        try visited.put(n.p, true);

        for (aoclib.FOUR_WAY) |d| {
            const p = n.p.add(d);
            if (p.c < 0 or p.r < 0 or p.c > 70 or p.r > 70) {
                continue;
            }
            if (corrupted.contains(p)) {
                continue;
            }

            const old_cost = dist.get(p);

            if (old_cost == null or n.c + 1 < old_cost.?) {
                try q.add(.{ .p = p, .c = n.c + 1 });
                try dist.put(p, n.c + 1);
            }
        }
    }

    return null;
}

pub fn part1(this: *const @This()) !?i64 {
    var iter = mem.tokenizeAny(u8, this.input, "\n");

    var corrupted = std.AutoHashMap(aoclib.P2D(i64), bool).init(this.allocator);
    defer corrupted.deinit();

    var ct: usize = 0;
    while (iter.next()) |line| {
        const x, const y = aoclib.splitOnce(line, ",");
        const xx = try std.fmt.parseInt(i64, x, 10);
        const yy = try std.fmt.parseInt(i64, y, 10);
        try corrupted.put(.{ .r = yy, .c = xx }, true);
        if (ct > 1024) {
            break;
        }
        ct += 1;
    }

    return shortestPath(&corrupted, this.allocator);
}

pub fn part2(this: *const @This()) !?aoclib.P2D(i64) {
    var iter = mem.tokenizeAny(u8, this.input, "\n");

    var corrupted = std.AutoHashMap(aoclib.P2D(i64), bool).init(this.allocator);
    defer corrupted.deinit();

    var ct: usize = 0;
    while (iter.next()) |line| {
        const x, const y = aoclib.splitOnce(line, ",");
        const xx = try std.fmt.parseInt(i64, x, 10);
        const yy = try std.fmt.parseInt(i64, y, 10);
        try corrupted.put(.{ .r = yy, .c = xx }, true);
        if (ct > 1024) {
            if (try shortestPath(&corrupted, this.allocator) == null) {
                return .{ .r = yy, .c = xx };
            }
        }
        ct += 1;
    }
    return null;
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
