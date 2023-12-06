const std = @import("std");
const input = @embedFile("input.txt");
// const input = "467..114..\n...*......\n..35..633.\n......#...\n617*......\n.....+.58.\n..592.....\n......755.\n...$.*....\n.664.598..";
var gpa = std.heap.GeneralPurposeAllocator(.{}){};

const Number = struct {
    value: i32,
    coords_start: @Vector(2, i32), // row, col
    coords_end: @Vector(2, i32),
};

const Symbol = struct {
    symbol: u8,
    coords: @Vector(2, i32),
};

pub fn main() !void {
    var lines: [140][]const u8 = undefined;
    var it = std.mem.tokenize(u8, input, "\n");

    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var numbers = std.ArrayList(Number).init(alloc);
    defer numbers.deinit();
    var symbols = std.ArrayList(Symbol).init(alloc);
    defer symbols.deinit();

    {
        var i: usize = 0;
        while (it.next()) |l| : (i += 1) {
            lines[i] = l;
        }
    }

    //get numbers and symbols
    {
        var i: usize = 0;
        while (i < lines.len) : (i += 1) {
            var j: usize = 0;
            while (j < lines[i].len) : (j += 1) {
                var row = @as(i32, @intCast(i));
                var start_col = @as(i32, @intCast(j));
                switch (lines[i][j]) {
                    '0'...'9' => {
                        var jj = j;
                        while (jj < lines[i].len and lines[i][jj] >= '0' and lines[i][jj] <= '9') : (jj += 1) {}
                        const valuse = try std.fmt.parseInt(i32, lines[i][j..jj], 10);
                        j = jj - 1;
                        var end_col = @as(i32, @intCast(jj - 1));
                        try numbers.append(Number{ .value = valuse, .coords_start = @Vector(2, i32){ row, start_col }, .coords_end = @Vector(2, i32){ row, end_col } });
                    },
                    '.' => {
                        continue;
                    },
                    else => {
                        try symbols.append(Symbol{ .symbol = lines[i][j], .coords = @Vector(2, i32){ row, start_col } });
                    },
                }
            }
        }
    }

    //part1
    {
        var connected_numbers = std.ArrayList(Number).init(alloc);
        defer connected_numbers.deinit();

        for (numbers.items) |n| {
            for (symbols.items) |s| {
                if (try std.math.absInt(n.coords_start[0] - s.coords[0]) > 1) {
                    continue;
                }
                if (s.coords[1] < (n.coords_start[1] - 1)) {
                    continue;
                }
                if (s.coords[1] > (n.coords_end[1] + 1)) {
                    continue;
                }
                try connected_numbers.append(n);
            }
        }

        var sum1: i32 = 0;
        for (connected_numbers.items) |n| {
            sum1 += n.value;
            // std.debug.print("{any}\n", .{n});
        }

        std.debug.print("sum1: {any}\n", .{sum1});
    }

    {
        var sum: i32 = 0;
        var connected_nrs = std.ArrayList(Number).init(alloc);
        defer connected_nrs.deinit();
        for (symbols.items) |s| {
            //only interested in *
            if (s.symbol != '*') continue;

            connected_nrs.clearRetainingCapacity();
            for (numbers.items) |n| {
                if (try std.math.absInt(n.coords_start[0] - s.coords[0]) > 1) {
                    continue;
                }
                if (s.coords[1] < (n.coords_start[1] - 1)) {
                    continue;
                }
                if (s.coords[1] > (n.coords_end[1] + 1)) {
                    continue;
                }
                try connected_nrs.append(n);
            }
            if (connected_nrs.items.len != 2) continue;
            sum += connected_nrs.items[0].value * connected_nrs.items[1].value;
        }
        std.debug.print("sum2: {}", .{sum});
    }

    // const part1_solution = try part1(&lines);
    // std.debug.print("prt1: {}\n", .{part1_solution});
    //
    // const part2_solution = try part2(&lines);
    // std.debug.print("prt2: {}\n", .{part2_solution});
}
