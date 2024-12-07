const std = @import("std");
const mem = std.mem;
const aoclib = @import("aoclib");

input: []const u8,
allocator: mem.Allocator,

fn recurse(tgt: i64, revOps: *std.ArrayList(i64), concat: bool) !i64 {
    if (revOps.items.len == 1) {
        if (revOps.items[0] == tgt) {
            return tgt;
        } else {
            return 0;
        }
    }

    if (revOps.items.len >= 2) {
        const len = revOps.items.len;
        const first = revOps.orderedRemove(len - 1);
        const second = revOps.items[len - 2];

        revOps.items[len - 2] = first *% second;
        const mul = try recurse(tgt, revOps, concat);
        if (mul != 0) {
            return mul;
        }

        revOps.items[len - 2] = first +% second;
        const add = try recurse(tgt, revOps, concat);
        if (add != 0) {
            return add;
        }

        if (concat) {
            var v = first;
            var t = second;
            while (t > 0) {
                t = @divTrunc(t, 10);
                v *= 10;
            }
            v += second;
            revOps.items[len - 2] = v;
            const c = try recurse(tgt, revOps, concat);
            if (c != 0) {
                return c;
            }
        }

        try revOps.append(first);
        revOps.items[len - 2] = second;
        return 0;
    }

    return 0;
}

pub fn part1(this: *const @This()) !?i64 {
    var result: i64 = 0;
    var lines = mem.splitAny(u8, this.input, "\n");
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        const test_s, const ops_s = aoclib.splitOnce(line, ": ");
        const target = try std.fmt.parseInt(i64, test_s, 10);
        var operands = try aoclib.intsAny(ops_s, " ", this.allocator);
        defer operands.deinit();

        aoclib.reverseList(i64, &operands);

        result += try recurse(target, &operands, false);
    }

    return result;
}

pub fn part2(this: *const @This()) !?i64 {
    var result: i64 = 0;
    var lines = mem.splitAny(u8, this.input, "\n");
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        const test_s, const ops_s = aoclib.splitOnce(line, ": ");
        const target = try std.fmt.parseInt(i64, test_s, 10);
        var operands = try aoclib.intsAny(ops_s, " ", this.allocator);
        defer operands.deinit();

        aoclib.reverseList(i64, &operands);
        result += try recurse(target, &operands, true);
    }

    return result;
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
