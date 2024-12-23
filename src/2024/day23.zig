const std = @import("std");
const mem = std.mem;
const aoclib = @import("aoclib");

input: []const u8,
allocator: mem.Allocator,

fn lt(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.order(u8, lhs, rhs) == .lt;
}

fn sort(items: [][]const u8) void {
    std.mem.sort([]const u8, items, {}, lt);
}

fn toStr(items: [][]const u8, allocator: std.mem.Allocator) ![]const u8 {
    var a = std.ArrayList(u8).init(allocator);
    defer a.deinit();
    for (items, 0..) |item, i| {
        if (i > 0) {
            try a.append(',');
        }
        try a.appendSlice(item);
    }
    return a.toOwnedSlice();
}

pub fn part1(this: *const @This()) !?i64 {
    var g = std.StringHashMap(std.ArrayList([]const u8)).init(this.allocator);
    defer g.deinit();

    var iter = mem.tokenizeAny(u8, this.input, "\n");
    while (iter.next()) |line| {
        const a, const b = aoclib.splitOnce(line, "-");

        const aa = try g.getOrPut(a);
        if (!aa.found_existing) {
            aa.value_ptr.* = std.ArrayList([]const u8).init(this.allocator);
        }
        try aa.value_ptr.append(b);

        const bb = try g.getOrPut(b);
        if (!bb.found_existing) {
            bb.value_ptr.* = std.ArrayList([]const u8).init(this.allocator);
        }
        try bb.value_ptr.append(a);
    }

    var iter1 = g.iterator();
    var triples = std.StringHashMap(bool).init(this.allocator);
    defer triples.deinit();
    while (iter1.next()) |a| {
        const aa = a.key_ptr.*;
        for (a.value_ptr.items) |b| {
            if (mem.eql(u8, b, aa)) {
                continue;
            }
            if (g.get(b)) |cs| {
                for (cs.items) |c| {
                    if (mem.eql(u8, c, aa) or mem.eql(u8, c, b)) {
                        continue;
                    }
                    if (g.get(c)) |ds| {
                        for (ds.items) |d| {
                            if (mem.eql(u8, d, aa)) {
                                if (d[0] == 't' or c[0] == 't' or b[0] == 't') {
                                    var k = [3][]const u8{ b, c, d };
                                    sort(&k);
                                    const kk = try toStr(&k, this.allocator);
                                    try triples.put(kk, true);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    return triples.count();
}

const V = struct {
    x: []const u8,
};

// textbook implementation of bron-kerbosch algorithm for enumerating maximal cliques
fn bronkerbosch(r: std.StringHashMap(bool), p: std.StringHashMap(bool), x: std.StringHashMap(bool), e: std.StringHashMap(std.ArrayList([]const u8)), vvvv: *V, allocator: std.mem.Allocator) !void {
    if (p.count() == 0 and x.count() == 0) {
        var l = std.ArrayList([]const u8).init(allocator);
        defer l.deinit();
        var it = r.keyIterator();
        while (it.next()) |v| {
            try l.append(v.*);
        }
        sort(l.items);
        const xx = try toStr(l.items, allocator);
        // this leaks but it's too annoying to do any other way
        if (xx.len > vvvv.*.x.len) {
            vvvv.*.x = xx;
        }
        return;
    }

    var pp = try p.clone();
    var xx = try x.clone();

    var iter = p.keyIterator();
    while (iter.next()) |v| {
        var newR = std.StringHashMap(bool).init(allocator);
        var newP = std.StringHashMap(bool).init(allocator);
        var newX = std.StringHashMap(bool).init(allocator);
        defer newR.deinit();
        defer newP.deinit();
        defer newX.deinit();

        const neighbors = e.get(v.*);
        if (neighbors) |n| {
            for (n.items) |nn| {
                if (pp.contains(nn)) {
                    try newP.put(nn, true);
                }
                if (xx.contains(nn)) {
                    try newX.put(nn, true);
                }
            }
        }
        var iter2 = r.keyIterator();
        while (iter2.next()) |vv| {
            try newR.put(vv.*, true);
        }
        try newR.put(v.*, true);

        try bronkerbosch(newR, newP, newX, e, vvvv, allocator);

        _ = pp.remove(v.*);
        try xx.put(v.*, true);
    }
}

pub fn part2(this: *const @This()) !?[]const u8 {
    var g = std.StringHashMap(std.ArrayList([]const u8)).init(this.allocator);
    defer g.deinit();

    var p = std.StringHashMap(bool).init(this.allocator);
    const x = std.StringHashMap(bool).init(this.allocator);
    const r = std.StringHashMap(bool).init(this.allocator);

    var iter = mem.tokenizeAny(u8, this.input, "\n");
    while (iter.next()) |line| {
        const a, const b = aoclib.splitOnce(line, "-");

        const aa = try g.getOrPut(a);
        if (!aa.found_existing) {
            aa.value_ptr.* = std.ArrayList([]const u8).init(this.allocator);
        }
        try aa.value_ptr.append(b);

        const bb = try g.getOrPut(b);
        if (!bb.found_existing) {
            bb.value_ptr.* = std.ArrayList([]const u8).init(this.allocator);
        }
        try bb.value_ptr.append(a);

        try p.put(a, true);
        try p.put(b, true);
    }

    var v: V = .{
        .x = "",
    };

    try bronkerbosch(r, p, x, g, &v, this.allocator);

    return v.x;
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
