const std = @import("std");
const mem = std.mem;
const aoclib = @import("aoclib");

input: []const u8,
allocator: mem.Allocator,

fn visitGraph(start_loc: aoclib.P2D(i64), start_dir: aoclib.P2D(i64), grid: *aoclib.Grid2D, allocator: mem.Allocator) !std.AutoHashMap(aoclib.P2D(i64), aoclib.P2D(i64)) {
    var visited = std.AutoHashMap(aoclib.P2D(i64), aoclib.P2D(i64)).init(allocator);
    errdefer visited.deinit();

    var loc = start_loc;
    var dir = start_dir;

    while (grid.get(loc) == '.') {
        try visited.put(loc, dir);
        const next = loc.add(dir);

        if (grid.get(next) == '#') {
            dir = dir.rotate_right();
        } else {
            loc = next;
        }
    }

    return visited;
}

pub fn part1(this: *const @This()) !?i64 {
    var grid = try aoclib.Grid2D.init(this.allocator, this.input);
    defer grid.deinit();

    var start_loc = grid.min_bounds;
    var start_dir = aoclib.UP;
    var loc = grid.min_bounds;

    outer: while (loc.r <= grid.max_bounds.r) {
        loc.c = 0;
        while (loc.c <= grid.max_bounds.c) {
            const c = grid.get(loc);
            if (c == '^') {
                start_loc = loc;
                start_dir = aoclib.UP;
                try grid.put(loc, '.');
                break :outer;
            }
            loc.c += 1;
        }
        loc.r += 1;
    }

    var path = try visitGraph(start_loc, start_dir, &grid, this.allocator);
    defer path.deinit();

    return path.count();
}

pub fn part2(this: *const @This()) !?i64 {
    var grid = try aoclib.Grid2D.init(this.allocator, this.input);
    defer grid.deinit();

    var start_loc = grid.min_bounds;
    var start_dir = aoclib.UP;
    var loc = grid.min_bounds;

    var possible_rows = std.AutoHashMap(i64, bool).init(this.allocator);
    defer possible_rows.deinit();
    var possible_cols = std.AutoHashMap(i64, bool).init(this.allocator);
    defer possible_cols.deinit();

    while (loc.r <= grid.max_bounds.r) {
        loc.c = 0;
        while (loc.c <= grid.max_bounds.c) {
            const c = grid.get(loc);
            if (c == '^') {
                start_loc = loc;
                start_dir = aoclib.UP;
                try grid.put(loc, '.');
            } else if (c == '#') {
                try possible_cols.put(loc.c - 1, true);
                try possible_cols.put(loc.c + 1, true);
                try possible_rows.put(loc.r - 1, true);
                try possible_rows.put(loc.r + 1, true);
            }
            loc.c += 1;
        }
        loc.r += 1;
    }

    var path = try visitGraph(start_loc, start_dir, &grid, this.allocator);
    defer path.deinit();

    var iter = path.keyIterator();
    var ct: i64 = 0;
    while (iter.next()) |obstacle| {
        const obs = obstacle.*;
        if (!possible_rows.contains(obs.r) and !possible_cols.contains(obs.c)) {
            continue;
        }

        var visited = std.AutoHashMap([2]aoclib.P2D(i64), bool).init(this.allocator);
        errdefer visited.deinit();

        loc = start_loc;
        var dir = start_dir;
        var loop = false;

        while (grid.get(loc) == '.') {
            const p = [2]aoclib.P2D(i64){ loc, dir };
            if (visited.contains(p)) {
                loop = true;
                break;
            }
            try visited.put(p, true);
            const next = loc.add(dir);

            if (grid.get(next) == '#' or next.eql(obs)) {
                dir = dir.rotate_right();
            } else {
                loc = next;
            }
        }
        if (loop) {
            ct += 1;
        }
    }

    return ct;
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
