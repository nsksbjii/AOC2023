const std = @import("std");
// const input = @embedFile("input.txt");
const input = "467..114..\n...*......\n..35..633.\n......#...\n617*......\n.....+.58.\n..592.....\n......755.\n...$.*....\n.664.598..";
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub fn main() !void {
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();

    var lines = std.ArrayList([]const u8).init(alloc);
    defer lines.deinit();

    var it = std.mem.tokenize(u8, input, "\n");

    while (it.next()) |l| {
        try lines.append(l);
    }

    const part1_solution = try part1(&lines);
    std.debug.print("prt1: {}\n", .{part1_solution});

    const part2_solution = try part2(&lines);
    std.debug.print("prt2: {}\n", .{part2_solution});
}

fn part1(lines: *std.ArrayList([]const u8)) !usize {
    var sum: usize = 0;
    var i: usize = 0;
    while (i < lines.items.len) : (i += 1) {
        var j: usize = 0;
        while (j < lines.items[i].len) : (j += 1) {
            switch (lines.items[i][j]) {
                '.' => {
                    continue;
                },
                '0'...'9' => {
                    sum += blk: {
                        var jj: usize = j;
                        var connected_to_symbol = false;
                        while (jj < lines.items[i].len and lines.items[i][jj] >= '0' and lines.items[i][jj] <= '9') : (jj += 1) {
                            var min_i = if (i > 0) i - 1 else i;
                            var max_i = if (i < lines.items.len - 1) i + 1 else i;
                            var min_jj = if (jj > 0) jj - 1 else jj;
                            var max_jj = if (jj < lines.items.len - 1) jj + 1 else jj;

                            if (connected_to_symbol) continue;
                            outer: for (min_i..max_i + 1) |ii| {
                                for (min_jj..max_jj + 1) |jjj| {
                                    switch (lines.items[ii][jjj]) {
                                        '.' => {
                                            continue;
                                        },
                                        '0'...'9' => {
                                            continue;
                                        },
                                        else => {
                                            connected_to_symbol = true;
                                            break :outer;
                                        },
                                    }
                                }
                            }
                        }
                        var num = try std.fmt.parseInt(usize, lines.items[i][j..jj], 10);

                        j = jj;
                        if (connected_to_symbol) {
                            // std.debug.print("num {}\n ", .{num});
                            break :blk num;
                        }
                        break :blk 0;
                    };
                },

                else => {
                    continue;
                },
            }
        }
    }
    return sum;
}

const Number = struct {
    row: usize,
    start_col: usize,
    len: usize,
};
const Gear = struct {
    row: usize,
    col: usize,
    neigbours: std.ArrayList(Number) = undefined,
    pub fn deinit(self: *const Gear) void {
        self.neigbours.deinit();
    }
};

fn part2(lines: *std.ArrayList([]const u8)) !usize {
    const alloc = gpa.allocator();

    var gears = std.ArrayList(Gear).init(alloc);
    defer {
        for (gears.items) |g| {
            g.deinit();
        }
        gears.deinit();
    }

    var numbers = std.ArrayList(Number).init(alloc);
    defer numbers.deinit();

    var i: usize = 0;
    while (i < lines.items.len) : (i += 1) {
        var j: usize = 0;
        while (j < lines.items[i].len) : (j += 1) {
            switch (lines.items[i][j]) {
                '*' => {
                    try gears.append(Gear{ .row = i, .col = j });
                },
                '0'...'9' => {
                    var jj: usize = j;
                    while (jj < lines.items[i].len and lines.items[i][jj] <= '9' and lines.items[i][jj] >= '0') : (jj += 1) {}
                    try numbers.append(Number{ .row = i, .start_col = j, .len = jj - j });
                },
                else => {
                    continue;
                },
            }
        }
    }
    for (gears.items) |*g| {
        var nn = std.ArrayList(Number).init(alloc);
        g.neigbours = &nn;
        for (numbers.items) |n| {
            const num = n;
            if (try std.math.absInt(@as(isize, @intCast(n.row)) - @as(isize, @intCast(g.row))) != 1) {
                try g.neigbours.append(num);
                continue;
            }
            if (if (n.start_col > 0) n.start_col - 1 <= g.col else true and n.start_col + n.len + 1 >= g.col) {
                try g.neigbours.append(num);

                continue;
            }
        }
    }
    var sum: usize = 0;
    for (gears.items) |g| {
        std.debug.print("{}", .{g});
        if (g.neigbours.items.len != 2) continue;
        sum += try std.fmt.parseInt(u8, lines.items[g.neigbours.items[0].row][g.neigbours.items[0].start_col .. g.neigbours.items[0].start_col + g.neigbours.items[0].len], 10) * try std.fmt.parseInt(u8, lines.items[g.neigbours.items[1].row][g.neigbours.items[1].start_col .. g.neigbours.items[1].start_col + g.neigbours.items[1].len], 10);
    }
    return sum;
}
