const std = @import("std");
const fs = std.fs;
const io = std.io;
const heap = std.heap;
const mem = std.mem;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

pub fn splitOnce(s: []const u8, delimiter: []const u8) [2][]const u8 {
    const idx = mem.indexOf(u8, s, delimiter);
    if (idx == null) {
        return [2][]const u8{ s, "" };
    } else {}
    return [2][]const u8{ s[0..idx.?], s[idx.? + delimiter.len ..] };
}

pub fn eqleql(comptime T: type, a: [][]const T, b: [][]const T) bool {
    if (a.len != b.len) {
        return false;
    }

    for (a, b) |aa, bb| {
        if (!mem.eql(T, aa, bb)) {
            return false;
        }
    }

    return true;
}

pub fn stringsAny(s: []const u8, delimiters: []const u8, allocator: Allocator) !ArrayList([]const u8) {
    var iter = mem.tokenizeAny(u8, s, delimiters);
    var l = ArrayList([]const u8).init(allocator);
    errdefer l.deinit();

    while (iter.next()) |v| {
        try l.append(v);
    }

    return l;
}

pub fn intsAny(s: []const u8, delimiters: []const u8, allocator: Allocator) !ArrayList(i64) {
    var iter = mem.tokenizeAny(u8, s, delimiters);
    var l = ArrayList(i64).init(allocator);
    errdefer l.deinit();

    while (iter.next()) |v| {
        try l.append(try std.fmt.parseInt(i64, v, 10));
    }

    return l;
}

pub fn sign(i: i64) i64 {
    if (i < 0) {
        return -1;
    } else if (i > 0) {
        return 1;
    } else {
        return 0;
    }
}

pub fn StringGraph(comptime E: type) type {
    return struct {
        allocator: Allocator,
        inner: std.StringHashMap(std.StringHashMap(E)),
        const Self = @This();

        pub fn init(allocator: Allocator) Self {
            return .{
                .inner = std.StringHashMap(std.StringHashMap(E)).init(allocator),
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            var it = self.inner.valueIterator();
            while (it.next()) |v| {
                v.deinit();
            }

            self.inner.deinit();
        }

        pub fn upsertEdge(self: *Self, from: []const u8, to: []const u8, data: E) !void {
            var entry = try self.inner.getOrPut(from);
            if (!entry.found_existing) {
                entry.value_ptr.* = std.StringHashMap(E).init(self.allocator);
                errdefer entry.value_ptr.deinit();
            }
            try entry.value_ptr.put(to, data);
            var entry2 = try self.inner.getOrPut(to);
            if (!entry2.found_existing) {
                entry2.value_ptr.* = std.StringHashMap(E).init(self.allocator);
                errdefer entry2.value_ptr.deinit();
            }
        }

        pub fn getAdjacentVertices(self: Self, from: []const u8) std.StringHashMap(E).KeyIterator {
            if (self.inner.get(from)) |v| {
                return v.keyIterator();
            }
            return .{
                .len = 0,
                .metadata = undefined,
                .items = undefined,
            };
        }

        pub fn getEdgeValue(self: Self, from: []const u8, to: []const u8) ?E {
            if (self.inner.get(from)) |m| {
                return m.get(to);
            }
            return null;
        }

        pub fn selectSubgraph(self: Self, vertices: [][]const u8) !StringGraph(E) {
            var subgraph = StringGraph(E).init(self.allocator);
            errdefer subgraph.deinit();

            var verticesSet = std.StringHashMap(bool).init(self.allocator);
            defer verticesSet.deinit();
            for (vertices) |v| {
                try verticesSet.put(v, true);
            }

            var iter = self.inner.keyIterator();
            while (iter.next()) |from| {
                var inner2 = self.inner.get(from.*).?;
                var iter2 = inner2.keyIterator();
                while (iter2.next()) |to| {
                    if (verticesSet.contains(from.*) and verticesSet.contains(to.*)) {
                        try subgraph.upsertEdge(from.*, to.*, inner2.get(to.*).?);
                    }
                }
            }
            return subgraph;
        }

        pub fn topologicalOrdering(self: Self) !std.ArrayList([]const u8) {
            var indegree = std.StringHashMap(usize).init(self.allocator);
            defer indegree.deinit();

            var iter = self.inner.keyIterator();
            while (iter.next()) |from| {
                try indegree.put(from.*, 0);
            }

            var iter2 = self.inner.valueIterator();
            while (iter2.next()) |inner2| {
                var iter3 = inner2.keyIterator();
                while (iter3.next()) |to| {
                    indegree.getEntry(to.*).?.value_ptr.* += 1;
                }
            }

            var ordered = std.ArrayList([]const u8).init(self.allocator);
            errdefer ordered.deinit();
            var stk = std.ArrayList([]const u8).init(self.allocator);
            defer stk.deinit();

            var iter4 = self.inner.keyIterator();
            while (iter4.next()) |v| {
                if (indegree.get(v.*).? == 0) {
                    try stk.append(v.*);
                }
            }

            while (stk.items.len > 0) {
                const n = stk.pop();
                try ordered.append(n);

                var iter5 = self.getAdjacentVertices(n);
                while (iter5.next()) |to| {
                    const entry = indegree.getEntry(to.*).?;
                    entry.value_ptr.* -= 1;
                    if (entry.value_ptr.* == 0) {
                        try stk.append(to.*);
                    }
                }
            }

            return ordered;
        }
    };
}

pub fn P2D(comptime T: type) type {
    return struct {
        r: T,
        c: T,

        const Self = @This();

        pub fn eql(self: Self, other: P2D(T)) bool {
            return self.r == other.r and self.c == other.c;
        }

        pub fn add(self: Self, b: P2D(T)) P2D(T) {
            return .{ .r = self.r + b.r, .c = self.c + b.c };
        }

        pub fn sub(self: Self, b: P2D(T)) P2D(T) {
            return .{ .r = self.r - b.r, .c = self.c - b.c };
        }

        pub fn scalar_mul(self: Self, b: i64) P2D(T) {
            return .{ .r = self.r * b, .c = self.c * b };
        }

        pub fn max(self: Self, b: P2D(T)) P2D(T) {
            return .{ .r = if (self.r > b.r) self.r else b.r, .c = if (self.c > b.c) self.c else b.c };
        }

        pub fn min(self: Self, b: P2D(T)) P2D(T) {
            return .{ .r = if (self.r < b.r) self.r else b.r, .c = if (self.c < b.c) self.c else b.c };
        }

        pub fn matmul(self: Self, m: [2]P2D(T)) P2D(T) {
            return .{ .r = self.r * m[0].r + self.c * m[1].r, .c = self.r * m[0].c + self.c * m[1].c };
        }

        pub fn rotate_left(self: Self) P2D(T) {
            return self.matmul([2]P2D(T){ .{ .r = 0, .c = 1 }, .{ .r = -1, .c = 0 } });
        }

        pub fn rotate_right(self: Self) P2D(T) {
            return self.matmul([2]P2D(T){ .{ .r = 0, .c = -1 }, .{ .r = 1, .c = 0 } });
        }
    };
}

pub const UP = P2D(i64){ .r = -1, .c = 0 };
pub const DOWN = P2D(i64){ .r = 1, .c = 0 };
pub const LEFT = P2D(i64){ .r = 0, .c = -1 };
pub const RIGHT = P2D(i64){ .r = 0, .c = 1 };
pub const UP_LEFT = UP.add(LEFT);
pub const UP_RIGHT = UP.add(RIGHT);
pub const DOWN_LEFT = DOWN.add(LEFT);
pub const DOWN_RIGHT = DOWN.add(RIGHT);
pub const FOUR_WAY = [_]P2D(i64){ UP, DOWN, LEFT, RIGHT };
pub const EIGHT_WAY = [_]P2D(i64){ UP, DOWN, LEFT, RIGHT, UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT };

pub const Grid2D = struct {
    allocator: Allocator,
    grid: std.AutoHashMap(P2D(i64), u8),
    min_bounds: P2D(i64),
    max_bounds: P2D(i64),

    const Self = @This();

    pub fn init(allocator: Allocator, str: []const u8) !Self {
        var grid = std.AutoHashMap(P2D(i64), u8).init(allocator);
        var iter = mem.splitAny(u8, str, "\n");
        var min_bounds = P2D(i64){ .r = 0, .c = 0 };
        var max_bounds = P2D(i64){ .r = 0, .c = 0 };

        var loc = P2D(i64){ .r = 0, .c = 0 };
        while (iter.next()) |line| {
            for (line, 0..) |v, c| {
                loc.c = @as(i64, @intCast(c));
                try grid.put(loc, v);
            }
            min_bounds = min_bounds.min(loc);
            max_bounds = max_bounds.max(loc);
            loc.r += 1;
        }

        return .{
            .min_bounds = min_bounds,
            .max_bounds = max_bounds,
            .allocator = allocator,
            .grid = grid,
        };
    }

    pub fn put(self: *Self, p: P2D(i64), v: u8) !void {
        try self.grid.put(p, v);
    }

    pub fn get(self: Self, p: P2D(i64)) u8 {
        if (self.grid.get(p)) |v| {
            return v;
        }
        return 0;
    }

    pub fn debug(self: Self) void {
        var loc = self.min_bounds;

        while (loc.r <= self.max_bounds.r) {
            std.debug.print("\n", .{});
            loc.c = 0;
            while (loc.c <= self.max_bounds.c) {
                const v = self.get(loc);
                std.debug.print("{c}", .{v});
                loc.c += 1;
            }
            loc.r += 1;
        }
    }

    pub fn deinit(self: *Self) void {
        self.grid.deinit();
    }
};

pub fn reverseList(comptime T: type, list: *std.ArrayList(T)) void {
    for (0..list.items.len / 2) |i| {
        const temp = list.items[i];
        list.items[i] = list.items[list.items.len - i - 1];
        list.items[list.items.len - i - 1] = temp;
    }
}
