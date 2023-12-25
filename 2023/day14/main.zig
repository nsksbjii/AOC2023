const std = @import("std");
const tokenize = std.mem.tokenize;
const split = std.mem.split;

const input = @embedFile("input.txt");
const input_size = 100;

const Arr = std.ArrayList;

fn tilt(grid: *[input_size][input_size]u8, dir: u8) void {
    var tilted = true;
    while (tilted) {
        var i: usize = if (dir == 'N' or dir == 'W') input_size - 1 else 0;
        tilted = false;
        while (true) {
            for (0..input_size) |j| {
                switch (dir) {
                    'N' => {
                        if (grid[i][j] == 'O' and grid[i - 1][j] == '.') {
                            // std.debug.print("sadsad\n", .{});
                            grid[i][j] = '.';
                            grid[i - 1][j] = 'O';
                            tilted = true;
                        }
                        // std.debug.print("i{}j:{}\n", .{ i, j });
                    },
                    'S' => {
                        if (grid[i][j] == 'O' and grid[i + 1][j] == '.') {
                            grid[i][j] = '.';
                            grid[i + 1][j] = 'O';
                            tilted = true;
                        }
                    },
                    'E' => {
                        if (grid[j][i] == 'O' and grid[j][i + 1] == '.') {
                            grid[j][i] = '.';
                            grid[j][i + 1] = 'O';
                            tilted = true;
                        }
                    },
                    'W' => {
                        // std.debug.print("WEet", .{});
                        if (grid[j][i] == 'O' and grid[j][i - 1] == '.') {
                            grid[j][i] = '.';
                            grid[j][i - 1] = 'O';
                            tilted = true;
                        }

                        // std.debug.print("i{}j:{}\n", .{ i, j });
                    },
                    else => {
                        unreachable;
                    },
                }
            }
            if (dir == 'N' or dir == 'W') i -= 1 else i += 1;
            if (i == 0 or i == input_size - 1) break;
        }
    }
}
fn calc_load(grid: [input_size][input_size]u8) usize {
    var i: usize = 0;
    var load: usize = 0;
    while (i < input_size) : (i += 1) {
        for (grid[i]) |rock| {
            if (rock == 'O') load += input_size - i;
        }
    }
    return load;
}

fn cycle(grid: *[input_size][input_size]u8, cycle_count: usize) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    var prevs = std.AutoHashMap(u64, usize).init(alloc);
    var modd: usize = undefined;
    defer prevs.deinit();
    var cycle_size: usize = 0;
    for (0..cycle_count) |i| {
        // print_grid(grid.*);
        // std.debug.print("tilting North\n", .{});
        tilt(grid, 'N');
        // print_grid(grid.*);
        // std.debug.print("tilting West\n", .{});
        tilt(grid, 'W');
        // print_grid(grid.*);
        // std.debug.print("tilting South\n", .{});
        tilt(grid, 'S');
        // print_grid(grid.*);
        // std.debug.print("tilting East\n", .{});
        tilt(grid, 'E');
        // print_grid(grid.*);
        //
        // print_grid(grid.*);
        var hash1: u64 = 0;
        for (grid) |j| {
            hash1 = std.hash.Wyhash.hash(hash1, &j);
        }

        if (prevs.get(hash1)) |j| {
            // std.debug.print("{} -> {}   {}\n", .{ i, j, i - j });
            if (cycle_size == 0) {
                cycle_size = i - j;
                modd = @mod(cycle_count, cycle_size) - 1;
                continue;
            }
            if (@mod(i, cycle_size) == modd) break;
        } else try prevs.put(hash1, i);
    }
}
fn print_grid(grid: [input_size][input_size]u8) void {
    for (grid) |i| {
        std.debug.print("{s}\n", .{i[0..input_size]});
    }
    std.debug.print("\n", .{});
}

pub fn main() !void {
    var grid: [input_size][input_size]u8 = undefined;
    { //read input into grid to make it mutable
        var it = tokenize(u8, input, "\n");
        var i: usize = 0;
        while (it.next()) |line| : (i += 1) {
            grid[i] = line[0..input_size].*;
        }
    }

    // print_grid(grid);
    try cycle(&grid, 1000000000);
    // print_grid(grid);
    const load = calc_load(grid);
    std.debug.print("lead: {}\n", .{load});
}
