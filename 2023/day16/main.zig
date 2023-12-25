const std = @import("std");
const tokenize = std.mem.tokenize;
const split = std.mem.split;

const input = @embedFile("input.txt");
const input_size = 110;

const Arr = std.ArrayList;

const Direction = enum {
    north,
    east,
    south,
    west,
};

//beam enters top left going east
// | - split beam
// /\ reflect it
//
const Cell = struct {
    symbol: u8,
    beams: usize = 0,
    beam_dirs: [4]?Direction = .{
        null,
        null,
        null,
        null,
    },
};

fn print_grid(grid: [input_size][input_size]Cell) void {
    for (0..input_size) |i| {
        for (0..input_size) |j| {
            std.debug.print("{c}", .{grid[i][j].symbol});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
}
fn print_grid_beams(grid: [input_size][input_size]Cell) void {
    for (0..input_size) |i| {
        for (0..input_size) |j| {
            if (grid[i][j].beams > 0) {
                std.debug.print("#", .{});
            } else {
                std.debug.print(".", .{});
            }
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
}
fn propagate_ray(x: usize, y: usize, direction: Direction, grid: *[input_size][input_size]Cell, depth: usize) void {
    const sym = grid[x][y].symbol;
    for (0..grid[x][y].beam_dirs.len) |i| {
        if (grid[x][y].beam_dirs[i]) |j| {
            if (j == direction) return;
            continue;
        }
        if (sym != '.') grid[x][y].beam_dirs[i] = direction;
        break;
    } else {
        std.debug.print("{},{} {c} {}\n", .{ x, y, sym, depth });
        return;
    }
    grid[x][y].beams += 1;

    //^^^^^ UP x--
    if (direction == Direction.north and (sym == '|' or sym == '.') and x > 0) propagate_ray(x - 1, y, direction, grid, depth + 1);
    if (direction == Direction.north and sym == '-' and y > 0) propagate_ray(x, y - 1, Direction.west, grid, depth + 1);
    if (direction == Direction.north and sym == '-' and y < input_size - 1) propagate_ray(x, y + 1, Direction.east, grid, depth + 1);
    if (direction == Direction.north and sym == '\\' and y > 0) propagate_ray(x, y - 1, Direction.west, grid, depth + 1);
    if (direction == Direction.north and sym == '/' and y < input_size - 1) propagate_ray(x, y + 1, Direction.east, grid, depth + 1);

    //>>>>>>> y++
    if (direction == Direction.east and (sym == '.' or sym == '-') and y < input_size - 1) propagate_ray(x, y + 1, Direction.east, grid, depth + 1);
    if (direction == Direction.east and sym == '\\' and x < input_size - 1) propagate_ray(x + 1, y, Direction.south, grid, depth + 1);
    if (direction == Direction.east and sym == '|' and x < input_size - 1) propagate_ray(x + 1, y, Direction.south, grid, depth + 1);
    if (direction == Direction.east and sym == '/' and x > 0) propagate_ray(x - 1, y, Direction.north, grid, depth + 1);
    if (direction == Direction.east and sym == '|' and x > 0) propagate_ray(x - 1, y, Direction.north, grid, depth + 1);

    //DOWN x++
    if (direction == Direction.south and (sym == '|' or sym == '.') and x < input_size - 1) propagate_ray(x + 1, y, direction, grid, depth + 1);
    if (direction == Direction.south and sym == '-' and y > 0) propagate_ray(x, y - 1, Direction.west, grid, depth + 1);
    if (direction == Direction.south and sym == '/' and y > 0) propagate_ray(x, y - 1, Direction.west, grid, depth + 1);
    if (direction == Direction.south and sym == '-' and y < input_size - 1) propagate_ray(x, y + 1, Direction.east, grid, depth + 1);
    if (direction == Direction.south and sym == '\\' and y < input_size - 1) propagate_ray(x, y + 1, Direction.east, grid, depth + 1);

    //<<<<<< y--
    if (direction == Direction.west and (sym == '.' or sym == '-') and y > 0) propagate_ray(x, y - 1, Direction.west, grid, depth + 1);
    if (direction == Direction.west and sym == '/' and x < input_size - 1) propagate_ray(x + 1, y, Direction.south, grid, depth + 1);
    if (direction == Direction.west and sym == '\\' and x > 0) propagate_ray(x - 1, y, Direction.north, grid, depth + 1);
    if (direction == Direction.west and sym == '|' and x > 0) propagate_ray(x - 1, y, Direction.north, grid, depth + 1);
    if (direction == Direction.west and sym == '|' and x < input_size - 1) propagate_ray(x + 1, y, Direction.south, grid, depth + 1);
}

fn count_energized_tiles(grid: [input_size][input_size]Cell) usize {
    var energized: usize = 0;
    for (grid) |i| {
        for (i) |j| {
            energized += if (j.beams > 0) 1 else 0;
        }
    }
    return energized;
}

pub fn main() !void {
    var grid: [input_size][input_size]Cell = undefined;
    var original_grid: [input_size][input_size]Cell = undefined;

    {
        var it = tokenize(u8, input, "\n");
        var i: usize = 0;
        while (it.next()) |line| : (i += 1) {
            for (0..input_size) |j| {
                grid[i][j] = Cell{ .symbol = line[j] };
                original_grid[i][j] = Cell{ .symbol = line[j] };
            }
        }
    }
    {
        // print_grid(grid);
        propagate_ray(0, 0, Direction.east, &grid, 0);
        // print_grid_beams(grid);
        const energized = count_energized_tiles(grid);
        std.debug.print("Part1: {}\n", .{energized});
    }

    {
        grid = original_grid;
        var i: usize = 0;
        var j: usize = 0;
        var max_energized: usize = 0;
        while (i < input_size) : (i += 1) {
            j = 0;
            while (j < input_size) : (j += 1) {
                grid = original_grid;
                if (i == 0) {
                    propagate_ray(i, j, Direction.south, &grid, 0);
                    const energized = count_energized_tiles(grid);
                    if (energized > max_energized) max_energized = energized;
                    continue;
                }
                if (j == 0) {
                    propagate_ray(i, j, Direction.east, &grid, 0);
                    const energized = count_energized_tiles(grid);
                    if (energized > max_energized) max_energized = energized;
                    continue;
                }
                if (i == input_size - 1) {
                    propagate_ray(i, j, Direction.north, &grid, 0);
                    const energized = count_energized_tiles(grid);
                    if (energized > max_energized) max_energized = energized;
                    continue;
                }
                if (j == input_size - 1) {
                    propagate_ray(i, j, Direction.west, &grid, 0);
                    const energized = count_energized_tiles(grid);
                    if (energized > max_energized) max_energized = energized;
                    continue;
                }
            }
        }
        std.debug.print("Part2: {}\n", .{max_energized});
    }
}
