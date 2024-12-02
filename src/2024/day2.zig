const std = @import("std");
const aoclib = @import("aoclib");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

fn isSafe(values: std.ArrayList(i64)) bool {
    var it = mem.window(i64, values.items, 2, 1);
    var safe = true;
    var signum: ?i64 = null;

    while (it.next()) |v| {
        const d = v[1] - v[0];
        const sig_d = aoclib.sign(d);
        if (signum == null) {
            signum = sig_d;
        }
        if ((sig_d != signum.?) or (@abs(d) < 1) or (@abs(d) > 3)) {
            safe = false;
            break;
        }
    }
    return safe;
}

pub fn part1(this: *const @This()) !?i64 {
    var lineIter = mem.tokenizeSequence(u8, this.input, "\n");

    var num_safe: i64 = 0;
    while (lineIter.next()) |line| {
        const values = try aoclib.intsAny(line, " ", this.allocator);
        defer values.deinit();

        if (isSafe(values)) {
            num_safe += 1;
        }
    }
    return num_safe;
}

pub fn part2(this: *const @This()) !?i64 {
    var lineIter = mem.tokenizeSequence(u8, this.input, "\n");

    var num_safe: i64 = 0;
    while (lineIter.next()) |line| {
        const values = try aoclib.intsAny(line, " ", this.allocator);
        defer values.deinit();

        if (isSafe(values)) {
            num_safe += 1;
        } else {
            for (0..values.items.len) |idx| {
                var values2 = std.ArrayList(i64).init(this.allocator);
                defer values2.deinit();

                for (values.items, 0..) |v, idx2| {
                    if (idx2 != idx) {
                        try values2.append(v);
                    }
                }

                if (isSafe(values2)) {
                    num_safe += 1;
                    break;
                }
            }
        }
    }
    return num_safe;
}

test "it should do nothing" {
    const allocator = std.testing.allocator;
    const input =
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
    ;

    const problem: @This() = .{
        .input = input,
        .allocator = allocator,
    };

    try std.testing.expectEqual(2, try problem.part1());
    try std.testing.expectEqual(4, try problem.part2());
}
