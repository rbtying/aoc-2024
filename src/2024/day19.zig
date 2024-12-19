const std = @import("std");
const mem = std.mem;
const aoclib = @import("aoclib");

input: []const u8,
allocator: mem.Allocator,

const R = struct {
    memo: std.StringHashMap(i64),
    patterns: std.ArrayList([]const u8),
    const Self = @This();

    fn recurse(self: *Self, s: []const u8) !i64 {
        if (s.len == 0) {
            return 1;
        }
        if (self.memo.get(s)) |r| {
            return r;
        }
        var sum: i64 = 0;

        for (self.patterns.items) |p| {
            if (mem.startsWith(u8, s, p)) {
                sum += try self.recurse(s[p.len..]);
            }
        }

        try self.memo.put(s, sum);

        return sum;
    }
};

pub fn part1(this: *const @This()) !?i64 {
    const patterns_, const designs = aoclib.splitOnce(this.input, "\n\n");
    const patterns = try aoclib.stringsAny(patterns_, ", ", this.allocator);
    defer patterns.deinit();

    var memo = std.StringHashMap(i64).init(this.allocator);
    defer memo.deinit();

    var sum: i64 = 0;
    var iter = mem.tokenizeAny(u8, designs, "\n");
    var x = R{ .memo = memo, .patterns = patterns };
    while (iter.next()) |design| {
        const result = try x.recurse(design);
        if (result > 0) {
            sum += 1;
        }
    }

    return sum;
}

pub fn part2(this: *const @This()) !?i64 {
    const patterns_, const designs = aoclib.splitOnce(this.input, "\n\n");
    const patterns = try aoclib.stringsAny(patterns_, ", ", this.allocator);
    defer patterns.deinit();

    var memo = std.StringHashMap(i64).init(this.allocator);
    defer memo.deinit();

    var sum: i64 = 0;
    var iter = mem.tokenizeAny(u8, designs, "\n");
    var x = R{ .memo = memo, .patterns = patterns };
    while (iter.next()) |design| {
        sum += try x.recurse(design);
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
