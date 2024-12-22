const std = @import("std");
const mem = std.mem;
const aoclib = @import("aoclib");

input: []const u8,
allocator: mem.Allocator,

fn derive(x: i64) i64 {
    var xx = x;
    xx = @mod((xx << 6) ^ xx, 16777216);
    xx = @mod((xx >> 5) ^ xx, 16777216);
    xx = @mod((xx * 2048) ^ xx, 16777216);
    return xx;
}

pub fn part1(this: *const @This()) !?i64 {
    const inputs = try aoclib.intsAny(this.input, "\n", this.allocator);
    defer inputs.deinit();

    var sum: i64 = 0;
    for (inputs.items) |orig_n| {
        var n = orig_n;
        for (0..2000) |_| {
            n = derive(n);
        }
        sum += n;
    }

    return sum;
}

pub fn part2(this: *const @This()) !?i64 {
    const inputs = try aoclib.intsAny(this.input, "\n", this.allocator);
    defer inputs.deinit();
    var scores = std.AutoHashMap([4]i64, i64).init(this.allocator);
    defer scores.deinit();

    for (inputs.items) |orig_n| {
        var n = orig_n;
        var seq = mem.zeroes([2001]i64);
        for (0..seq.len) |i| {
            seq[i] = @mod(n, 10);
            n = derive(n);
        }

        var windows = mem.window(i64, &seq, 5, 1);
        var visited = std.AutoHashMap([4]i64, bool).init(this.allocator);
        defer visited.deinit();
        while (windows.next()) |w| {
            const deltas = [4]i64{ w[1] - w[0], w[2] - w[1], w[3] - w[2], w[4] - w[3] };
            if (!visited.contains(deltas)) {
                try visited.put(deltas, true);
                const x = try scores.getOrPut(deltas);
                if (!x.found_existing) {
                    x.value_ptr.* = 0;
                }
                x.value_ptr.* += w[4];
            }
        }
    }

    var values = scores.valueIterator();
    var max: i64 = -1;
    while (values.next()) |v| {
        if (v.* > max) {
            max = v.*;
        }
    }

    return max;
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
