const std = @import("std");
const mem = std.mem;
const aoclib = @import("aoclib");

input: []const u8,
allocator: mem.Allocator,

pub fn part1(this: *const @This()) !?i64 {
    const rules, const lines = aoclib.splitOnce(this.input, "\n\n");

    var it = mem.tokenizeAny(u8, rules, "\n");
    var g = aoclib.StringGraph(i64).init(this.allocator);
    while (it.next()) |rule| {
        const from, const to = aoclib.splitOnce(rule, "|");
        try g.upsertEdge(from, to, 1);
    }
    var it2 = mem.tokenizeAny(u8, lines, "\n");
    var sum: i64 = 0;

    while (it2.next()) |line| {
        var ordered = true;
        const v = try aoclib.stringsAny(line, ",", this.allocator);
        defer v.deinit();

        for (v.items, 0..) |vv, idx| {
            var edgeIter = g.getAdjacentVertices(vv);
            while (edgeIter.next()) |to| {
                if (!g.inner.contains(to.*)) {
                    continue;
                }
                for (v.items[0..idx]) |vvv| {
                    if (mem.eql(u8, vvv, to.*)) {
                        ordered = false;
                    }
                }
            }
        }
        if (ordered) {
            sum += try std.fmt.parseInt(i64, v.items[v.items.len / 2], 10);
        }
    }

    return sum;
}

pub fn part2(this: *const @This()) !?i64 {
    const rules, const lines = aoclib.splitOnce(this.input, "\n\n");

    var it = mem.tokenizeAny(u8, rules, "\n");
    var g = aoclib.StringGraph(i64).init(this.allocator);
    while (it.next()) |rule| {
        const from, const to = aoclib.splitOnce(rule, "|");
        try g.upsertEdge(from, to, 1);
    }
    var it2 = mem.tokenizeAny(u8, lines, "\n");
    var sum: i64 = 0;

    while (it2.next()) |line| {
        const v = try aoclib.stringsAny(line, ",", this.allocator);
        defer v.deinit();
        var g2 = try g.selectSubgraph(v.items);
        defer g2.deinit();
        var ordered = try g2.topologicalOrdering();
        defer ordered.deinit();

        if (!aoclib.eqleql(u8, ordered.items, v.items)) {
            sum += try std.fmt.parseInt(i64, ordered.items[ordered.items.len / 2], 10);
        }
    }

    return sum;
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
