const std = @import("std");
const mem = std.mem;
const aoclib = @import("aoclib");

input: []const u8,
allocator: mem.Allocator,

fn soln(this: *const @This(), p1: bool) !?i64 {
    var grid = try aoclib.Grid2D.init(this.allocator, this.input);
    defer grid.deinit();

    var loc = grid.min_bounds;
    var antennaGroups = std.AutoHashMap(u8, std.ArrayList(aoclib.P2D(i64))).init(this.allocator);
    defer antennaGroups.deinit();
    var antinodes = std.AutoHashMap(aoclib.P2D(i64), bool).init(this.allocator);
    defer antinodes.deinit();

    while (loc.r <= grid.max_bounds.r) : (loc.r += 1) {
        loc.c = grid.min_bounds.c;
        while (loc.c <= grid.max_bounds.c) : (loc.c += 1) {
            const v = grid.get(loc);
            if (v == 0 or v == '.') {
                continue;
            }

            const entry = try antennaGroups.getOrPut(v);
            if (!entry.found_existing) {
                entry.value_ptr.* = std.ArrayList(aoclib.P2D(i64)).init(this.allocator);
                defer entry.value_ptr.*.deinit();
            }

            try entry.value_ptr.*.append(loc);
        }
    }

    var entryIter = antennaGroups.iterator();
    while (entryIter.next()) |entry| {
        const locs = entry.value_ptr.*;
        for (locs.items) |loc1| {
            for (locs.items) |loc2| {
                if (loc1.eql(loc2)) {
                    continue;
                }
                const delta = loc2.sub(loc1);

                var stk = std.ArrayList([2]aoclib.P2D(i64)).init(this.allocator);
                defer stk.deinit();
                try stk.append([2]aoclib.P2D(i64){ loc2, delta });
                while (stk.items.len > 0) {
                    const l, const d = stk.pop();
                    if (grid.get(l) != 0) {
                        if (!p1 or (l.sub(d.scalar_mul(2)).eql(loc1) and l.sub(d).eql(loc2))) {
                            try antinodes.put(l, true);
                        }
                        const n = l.add(d);
                        try stk.append([2]aoclib.P2D(i64){ n, d });
                    }
                }
            }
        }
    }

    return antinodes.count();
}

pub fn part1(this: *const @This()) !?i64 {
    return soln(this, true);
}

pub fn part2(this: *const @This()) !?i64 {
    return soln(this, false);
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
