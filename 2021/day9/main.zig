const std = @import("std");
const input = @embedFile("input.txt");

pub fn main() !void {
    var map: [100][100]u8 = undefined;

    var it = std.mem.tokenize(u8, input, "\n");

    var row_num: usize = 0;
    while (it.next()) |row| {
        for (row, 0..) |c, idx| {
            map[row_num][idx] = c - '0';
        }
        row_num += 1;
    }

    const part_one_solution = part1(&map);
    std.debug.print("part1: {}\n", .{part_one_solution});

    const part_two_solution = part2(&map);
    std.debug.print("part2: {}\n", .{part_two_solution});
}

fn part1(map: *[100][100]u8) usize {
    var danger_sum: usize = 0;

    var i: usize = 0;
    while (i < 100) : (i += 1) {
        var j: usize = 0;
        while (j < 100) : (j += 1) {
            const up = if (i > 0) map[i - 1][j] else 9;
            const down = if (i < 99) map[i + 1][j] else 9;
            const left = if (j > 0) map[i][j - 1] else 9;
            const right = if (j < 99) map[i][j + 1] else 9;

            const center = map[i][j];
            if (center < up and
                center < down and
                center < left and
                center < right)
            {
                danger_sum += center + 1;
            }
        }
    }
    return danger_sum;
}

fn part2(map: *[100][100]u8) usize {
    var basin_sizes = [1]usize{0} ** 2_500;

    var i: usize = 0;
    var basin_index: usize = 0;
    while (i < 100) : (i += 1) {
        var j: usize = 0;
        while (j < 100) : (j += 1) {
            if (map[i][j] == 9) continue;
            var basin_size: usize = 0;
            get_basin_size(map, i, j, &basin_size);
            basin_sizes[basin_index] = basin_size;
            basin_index += 1;
        }
    }

    std.mem.sort(usize, &basin_sizes, {}, comptime std.sort.desc(usize));

    var result: usize = 1;
    for (basin_sizes[0..3]) |d| result *= d;
    return result;
}

fn get_basin_size(map: *[100][100]u8, i: usize, j: usize, basin_size: *usize) void {
    // std.debug.print("{}", .{map[i][j]});
    basin_size.* += 1;
    map[i][j] = 9;

    const up = if (i > 0) map[i - 1][j] else 9;
    if (up != 9) get_basin_size(map, i - 1, j, basin_size);

    const down = if (i < 99) map[i + 1][j] else 9;
    if (down != 9) get_basin_size(map, i + 1, j, basin_size);

    const left = if (j > 0) map[i][j - 1] else 9;
    if (left != 9) get_basin_size(map, i, j - 1, basin_size);

    const right = if (j < 99) map[i][j + 1] else 9;
    if (right != 9) get_basin_size(map, i, j + 1, basin_size);
}
