const std = @import("std");
const fs = std.fs;
const io = std.io;
const heap = std.heap;
const mem = std.mem;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

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

pub fn P2D(comptime T: type) type {
    return struct {
        r: T,
        c: T,

        const Self = @This();

        pub fn add(self: Self, b: P2D(T)) P2D(T) {
            return .{ .r = self.r + b.r, .c = self.c + b.c };
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

    pub fn put(self: Self, p: P2D(i64), v: u8) !void {
        try self.grid.put(p, v);
    }

    pub fn get(self: Self, p: P2D(i64)) u8 {
        if (!self.grid.contains(p)) {
            return 0;
        }
        return self.grid.get(p).?;
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
