const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

pub fn part1(this: *const @This()) !?i64 {
    var list1 = std.ArrayList(i64).init(this.allocator);
    defer list1.deinit();
    var list2 = std.ArrayList(i64).init(this.allocator);
    defer list2.deinit();

    var lineIter = mem.tokenizeSequence(u8, this.input, "\n");

    while (lineIter.next()) |line| {
        var iter = mem.tokenizeSequence(u8, line, " ");
        try list1.append(try std.fmt.parseInt(i64, iter.next().?, 10));
        try list2.append(try std.fmt.parseInt(i64, iter.next().?, 10));
    }

    mem.sort(i64, list1.items, {}, std.sort.asc(i64));
    mem.sort(i64, list2.items, {}, std.sort.asc(i64));

    var totalDiff: i64 = 0;
    for (list1.items, list2.items) |a, b| {
        const diff = @abs(a - b);
        totalDiff += @intCast(diff);
    }

    return totalDiff;
}

pub fn part2(this: *const @This()) !?u64 {
    var list1 = std.ArrayList(u64).init(this.allocator);
    defer list1.deinit();
    var counter = std.AutoHashMap(u64, u64).init(this.allocator);
    defer counter.deinit();

    var lineIter = mem.tokenizeSequence(u8, this.input, "\n");

    while (lineIter.next()) |line| {
        var iter = mem.tokenizeSequence(u8, line, " ");
        try list1.append(try std.fmt.parseInt(u64, iter.next().?, 10));
        const c = try std.fmt.parseInt(u64, iter.next().?, 10);
        const v = try counter.getOrPut(c);
        if (!v.found_existing) {
            v.value_ptr.* = 0;
        }
        v.value_ptr.* += 1;
    }

    var similarity: u64 = 0;
    for (list1.items) |a| {
        const other = counter.get(a);
        if (other) |o| {
            similarity += o * a;
        }
    }

    return similarity;
}

test "it should return the right answer" {
    const allocator = std.testing.allocator;
    const input = "3   4\n4   3\n2   5\n1   3\n3   9\n3   3";

    const problem: @This() = .{
        .input = input,
        .allocator = allocator,
    };

    try std.testing.expectEqual(11, try problem.part1());
    try std.testing.expectEqual(31, try problem.part2());
}
