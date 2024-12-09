const std = @import("std");
const mem = std.mem;
const aoclib = @import("aoclib");

input: []const u8,
allocator: mem.Allocator,

const File = struct {
    fpos: usize,
    fnum: usize,
    flen: usize,
};

fn reverseFPos(_: void, a: File, b: File) std.math.Order {
    return std.math.order(b.fpos, a.fpos);
}

pub fn part1(this: *const @This()) !?u64 {
    var files = std.PriorityQueue(File, void, reverseFPos).init(this.allocator, {});
    defer files.deinit();
    var empties = std.ArrayList(File).init(this.allocator);
    defer empties.deinit();

    var pos: usize = 0;

    for (this.input, 0..) |c, idx| {
        if (std.ascii.isWhitespace(c)) {
            continue;
        }
        const is_file = idx % 2 == 0;
        const f = File{
            .fpos = pos,
            .fnum = idx / 2,
            .flen = try std.fmt.parseInt(usize, &[_]u8{c}, 10),
        };

        pos += f.flen;
        if (is_file) {
            try files.add(f);
        } else {
            try empties.append(f);
        }
    }

    aoclib.reverseList(File, &empties);

    while (empties.items.len > 0) {
        const f = files.remove();
        const e = empties.pop();

        if (e.fpos < f.fpos) {
            const min_l = @min(f.flen, e.flen);
            try files.add(.{
                .flen = min_l,
                .fpos = e.fpos,
                .fnum = f.fnum,
            });

            if (f.flen > e.flen) {
                try files.add(.{
                    .flen = f.flen - e.flen,
                    .fpos = f.fpos,
                    .fnum = f.fnum,
                });
            }
            if (e.flen > f.flen) {
                try empties.append(.{
                    .flen = e.flen - f.flen,
                    .fpos = e.fpos + min_l,
                    .fnum = e.fnum,
                });
            }
        } else {
            try files.add(f);
            break;
        }
    }

    var checksum: u64 = 0;
    var iter = files.iterator();
    while (iter.next()) |f| {
        for (0..f.flen) |idx| {
            checksum += f.fnum * (f.fpos + idx);
        }
    }

    return checksum;
}

pub fn part2(this: *const @This()) !?u64 {
    var files = std.PriorityQueue(File, void, reverseFPos).init(this.allocator, {});
    defer files.deinit();
    var empties = std.ArrayList(File).init(this.allocator);
    defer empties.deinit();

    var pos: usize = 0;

    for (this.input, 0..) |c, idx| {
        if (std.ascii.isWhitespace(c)) {
            continue;
        }
        const is_file = idx % 2 == 0;
        const f = File{
            .fpos = pos,
            .fnum = idx / 2,
            .flen = try std.fmt.parseInt(usize, &[_]u8{c}, 10),
        };

        pos += f.flen;
        if (is_file) {
            try files.add(f);
        } else {
            try empties.append(f);
        }
    }

    var new_files = std.PriorityQueue(File, void, reverseFPos).init(this.allocator, {});
    defer new_files.deinit();

    while (files.removeOrNull()) |f| {
        var found = false;
        for (0.., empties.items) |idx, e| {
            if (e.fpos > f.fpos) {
                break;
            }
            if (e.flen >= f.flen) {
                if (e.flen > f.flen) {
                    empties.items[idx].fpos += f.flen;
                    empties.items[idx].flen -= f.flen;
                } else {
                    _ = empties.orderedRemove(idx);
                }
                try new_files.add(.{
                    .fpos = e.fpos,
                    .flen = f.flen,
                    .fnum = f.fnum,
                });
                found = true;
                break;
            }
        }
        if (!found) {
            try new_files.add(f);
        }
    }

    var checksum: u64 = 0;
    var iter = new_files.iterator();
    while (iter.next()) |f| {
        for (0..f.flen) |idx| {
            checksum += f.fnum * (f.fpos + idx);
        }
    }

    return checksum;
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
