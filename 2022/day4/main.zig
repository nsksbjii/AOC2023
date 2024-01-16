const std = @import("std");
const input = @embedFile("input.txt");
const tokenize = std.mem.tokenize;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() !void {
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var elfs = std.ArrayList([2]usize).init(alloc);
    defer elfs.deinit();

    var it = tokenize(u8, input, "\n");

    while (it.next()) |line| {
        var tok = tokenize(u8, line, ",-");
        const elf1 = [2]usize{ try std.fmt.parseInt(usize, tok.next().?, 10), try std.fmt.parseInt(usize, tok.next().?, 10) };
        const elf2 = [2]usize{ try std.fmt.parseInt(usize, tok.next().?, 10), try std.fmt.parseInt(usize, tok.next().?, 10) };
        try elfs.append(elf1);
        try elfs.append(elf2);
    }

    { //part1

        var fully_contained: usize = 0;
        var i: usize = 0;
        while (i < elfs.items.len - 1) : (i += 2) {
            if (elfs.items[i][0] >= elfs.items[i + 1][0] and
                elfs.items[i][1] <= elfs.items[i + 1][1])
            {
                std.debug.print("elf: {any} is fully contained in {any}\n", .{ elfs.items[i], elfs.items[i + 1] });
                fully_contained += 1;
                continue;
            }

            if (elfs.items[i + 1][0] >= elfs.items[i][0] and
                elfs.items[i + 1][1] <= elfs.items[i][1])
            {
                std.debug.print("elf: {any} is fully contained in {any}\n", .{ elfs.items[i + 1], elfs.items[i] });
                fully_contained += 1;
                continue;
            }
        }

        std.debug.print("fully contained: {}\n", .{fully_contained});
    }

    { //part2

        var overlap: usize = 0;
        var i: usize = 0;
        while (i < elfs.items.len - 1) : (i += 2) {
            const l = elfs.items[i];
            const r = elfs.items[i + 1];
            if ((l[0] >= r[0] and l[0] <= r[1]) or (l[1] >= r[0] and l[1] <= r[1])) {
                overlap += 1;
                continue;
            }
            if ((r[0] >= l[0] and r[0] <= l[1]) or (r[1] >= l[0] and r[1] <= l[1])) {
                overlap += 1;
                continue;
            }
        }

        std.debug.print("fully contained: {}\n", .{overlap});
    }
}
