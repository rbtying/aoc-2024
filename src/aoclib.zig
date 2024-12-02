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
