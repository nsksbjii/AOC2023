const std = @import("std");
const input = @embedFile("input.txt");

var octopus = struct {
    energy: usize = undefined,
    spent: bool = false,
};

pub fn main() !void {
    var map: [10][10]u8 = undefined;

    var it = std.mem.tokenize(u8, input, "\n");

    var line_num: usize = 0;
    while (line_num < 10) : (line_num += 1) {
        const line = it.next().?;
        for (line, 0..) |c, idx| {
            map[line_num][idx] = c - '0';
        }
    }

    // std.debug.print("original map: {any}\n\n\n", .{map});
    const part_one = part1(&map);
    std.debug.print("Part1: {}\n", .{part_one});

    const part_two = part2(&map);
    std.debug.print("PArt2: {}\n", .{part_two});
}

fn part1(map: *[10][10]u8) usize {
    var flashes: usize = 0;
    var n: usize = 0;
    while (n < 100) : (n += 1) {
        var i: usize = 0;
        while (i < 10) : (i += 1) {
            var j: usize = 0;
            while (j < 10) : (j += 1) {
                map[i][j] += 1;
            }
        }
        cascadade(map, &flashes);
        // std.debug.print("{any}\n\n", .{map.*});
    }

    return flashes;
}

fn part2(map: *[10][10]u8) usize {
    var flashes: usize = 0;
    var n: usize = 0;
    while (true) {
        var i: usize = 0;
        while (i < 10) : (i += 1) {
            var j: usize = 0;
            while (j < 10) : (j += 1) {
                map[i][j] += 1;
            }
        }
        cascadade(map, &flashes);

        var all_zero: bool = true;
        check: for (map) |row| {
            for (row) |char| {
                if (char != 0) {
                    all_zero = false;
                    break :check;
                }
            }
        }

        if (all_zero) {
            std.debug.print("{any}", .{map.*});
            break;
        }
        n += 1;
    }

    return n;
}

fn cascadade(map: *[10][10]u8, flash_counter: *usize) void {
    var i: usize = 0;
    while (i < 10) : (i += 1) {
        var j: usize = 0;
        while (j < 10) : (j += 1) {
            if (map[i][j] <= 9) continue;
            flash_counter.* += 1;
            map[i][j] = 0;
            increment_adjacent(map, i, j);
            cascadade(map, flash_counter);
        }
    }
}

fn increment_adjacent(map: *[10][10]u8, i: usize, j: usize) void {
    const up = if (i > 0) &map[i - 1][j] else null;
    const down = if (i < 9) &map[i + 1][j] else null;
    const left = if (j > 0) &map[i][j - 1] else null;
    const right = if (j < 9) &map[i][j + 1] else null;
    const up_left = if (up != null and left != null) &map[i - 1][j - 1] else null;
    const up_right = if (up != null and right != null) &map[i - 1][j + 1] else null;
    const down_left = if (down != null and left != null) &map[i + 1][j - 1] else null;
    const down_right = if (down != null and right != null) &map[i + 1][j + 1] else null;

    const adjacent: [8]?*u8 = .{ up, down, left, right, up_left, up_right, down_left, down_right };

    var idx: usize = 0;
    while (idx < adjacent.len) : (idx += 1) {
        if (adjacent[idx] == null or adjacent[idx].?.* == 0) continue;
        adjacent[idx].?.* += 1;
    }
}
