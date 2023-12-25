const std = @import("std");
const token = std.mem.tokenize;
const input = @embedFile("input.txt");
const inputSize = 140;
const DLL = std.TailQueue(LoopPart);
const Node = DLL.Node;

const Direction = enum {
    north,
    south,
    east,
    west,
};

const Pipe = struct {
    label: u8,
    dir1: Direction = undefined,
    dir2: Direction = undefined,
    marker_dir: struct { a: Direction, b: Direction } = undefined,
};

const SSN = Pipe{ .label = 'S', .dir2 = Direction.north };
const SSS = Pipe{ .label = 'S', .dir2 = Direction.south };
const SSE = Pipe{ .label = 'S', .dir2 = Direction.east };
const SSW = Pipe{ .label = 'S', .dir2 = Direction.west };
const NW = Pipe{ .label = 'F', .dir1 = Direction.north, .dir2 = Direction.west, .marker_dir = .{ .a = Direction.east, .b = Direction.north } };
const NE = Pipe{ .label = '7', .dir1 = Direction.north, .dir2 = Direction.east, .marker_dir = .{ .a = Direction.east, .b = Direction.south } };
const SW = Pipe{ .label = 'L', .dir1 = Direction.south, .dir2 = Direction.west, .marker_dir = .{ .a = Direction.west, .b = Direction.north } };
const SE = Pipe{ .label = 'J', .dir1 = Direction.south, .dir2 = Direction.east, .marker_dir = .{ .a = Direction.west, .b = Direction.south } };
const NN = Pipe{ .label = '|', .dir1 = Direction.north, .dir2 = Direction.north, .marker_dir = .{ .a = Direction.east, .b = Direction.east } };
const EE = Pipe{ .label = '-', .dir1 = Direction.east, .dir2 = Direction.east, .marker_dir = .{ .a = Direction.south, .b = Direction.south } };
const ES = Pipe{ .label = 'F', .dir1 = Direction.east, .dir2 = Direction.south, .marker_dir = .{ .a = Direction.south, .b = Direction.west } };
const WS = Pipe{ .label = '7', .dir1 = Direction.west, .dir2 = Direction.south, .marker_dir = .{ .a = Direction.north, .b = Direction.west } };
const EN = Pipe{ .label = 'L', .dir1 = Direction.east, .dir2 = Direction.north, .marker_dir = .{ .a = Direction.south, .b = Direction.east } };
const WN = Pipe{ .label = 'J', .dir1 = Direction.west, .dir2 = Direction.north, .marker_dir = .{ .a = Direction.north, .b = Direction.east } };
const SS = Pipe{ .label = '|', .dir1 = Direction.south, .dir2 = Direction.south, .marker_dir = .{ .a = Direction.west, .b = Direction.west } };
const WW = Pipe{ .label = '-', .dir1 = Direction.west, .dir2 = Direction.west, .marker_dir = .{ .a = Direction.north, .b = Direction.north } };

const LoopPart = struct {
    pipe_piece: Pipe,
    x: usize,
    y: usize,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const gpalloc = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(gpalloc);
    defer arena.deinit();
    const alloc = arena.allocator();

    //read input
    var grid: [inputSize][]const u8 = undefined;
    var it = token(u8, input, "\n");
    var row: usize = 0;
    while (it.next()) |line| : (row += 1) {
        grid[row] = line;
    }

    //ind start X and Y
    var startRow: usize = 0;
    var startCol: usize = 0;
    out: for (0..inputSize) |x| {
        for (0..inputSize) |y| {
            if (grid[x][y] == 'S') {
                startRow = x;
                startCol = y;
                break :out;
            }
        }
    }
    const p = DLL;
    var loop = p{};
    try explorePipe(&grid, startRow, startCol, &loop, alloc);
    var enclosed = countEnclosed(grid, &loop);
    _ = enclosed;
}

fn explorePipe(grid: *[inputSize][]const u8, startRow: usize, startCol: usize, loop: *DLL, alloc: std.mem.Allocator) !void {
    var x: usize = startRow;
    var y: usize = startCol;

    //handle start
    if (grid[startRow][startCol] == 'S' and loop.len == 0) {
        if (x > 0 and std.mem.count(u8, "F7|", grid[x - 1][y .. y + 1]) == 1) {
            var start = try alloc.create(Node);
            start.data = LoopPart{ .pipe_piece = SSN, .x = x, .y = y };
            loop.append(start);
            x -= 1;
        } else if (x < inputSize - 1 and std.mem.count(u8, "JL|", grid[x + 1][y .. y + 1]) == 1) {
            var start = try alloc.create(Node);
            start.data = LoopPart{ .pipe_piece = SSS, .x = x, .y = y };
            loop.append(start);
            x += 1;
        } else if (y < inputSize - 1 and std.mem.count(u8, "J7-", grid[x][y + 1 .. y + 2]) == 1) {
            var start = try alloc.create(Node);
            start.data = LoopPart{ .pipe_piece = SSE, .x = x, .y = y };
            loop.append(start);
            y += 1;
        } else if (y > 0 and std.mem.count(u8, "FL-", grid[x][y - 1 .. y]) == 1) {
            var start = try alloc.create(Node);
            start.data = LoopPart{ .pipe_piece = SSW, .x = x, .y = y };
            loop.append(start);
            y -= 1;
        } else {
            unreachable;
        }
    }

    switch (grid[x][y]) {
        'L' => {
            std.debug.print("last dirL: {}\n", .{loop.last.?.data.pipe_piece.dir2});
            var new = try alloc.create(Node);
            switch (loop.last.?.data.pipe_piece.dir2) {
                Direction.south => {
                    new.data = LoopPart{ .pipe_piece = SW, .x = x, .y = y };
                    loop.append(new);
                    try explorePipe(grid, x, y + 1, loop, alloc);
                },
                Direction.east => {
                    new.data = LoopPart{ .pipe_piece = EN, .x = x, .y = y };
                    loop.append(new);
                    try explorePipe(grid, x - 1, y, loop, alloc);
                },
                else => {
                    unreachable;
                },
            }
        },
        'F' => {
            std.debug.print("last dirF: {}\n", .{loop.last.?.data.pipe_piece.dir2});
            var new = try alloc.create(Node);
            switch (loop.last.?.data.pipe_piece.dir2) {
                Direction.north => {
                    new.data = LoopPart{ .pipe_piece = NW, .x = x, .y = y };
                    loop.append(new);
                    try explorePipe(grid, x, y + 1, loop, alloc);
                },
                Direction.east => {
                    new.data = LoopPart{ .pipe_piece = ES, .x = x, .y = y };
                    loop.append(new);
                    try explorePipe(grid, x + 1, y, loop, alloc);
                },
                else => {
                    unreachable;
                },
            }
        },
        'J' => {
            std.debug.print("last dirJ: {}\n", .{loop.last.?.data.pipe_piece.dir2});
            var new = try alloc.create(Node);
            switch (loop.last.?.data.pipe_piece.dir2) {
                Direction.south => {
                    new.data = LoopPart{ .pipe_piece = SE, .x = x, .y = y };
                    loop.append(new);
                    try explorePipe(grid, x, y - 1, loop, alloc);
                },
                Direction.west => {
                    new.data = LoopPart{ .pipe_piece = WN, .x = x, .y = y };
                    loop.append(new);
                    try explorePipe(grid, x - 1, y, loop, alloc);
                },
                else => {
                    unreachable;
                },
            }
        },
        '7' => {
            std.debug.print("last dir7: {}\n", .{loop.last.?.data.pipe_piece.dir2});
            var new = try alloc.create(Node);
            switch (loop.last.?.data.pipe_piece.dir2) {
                Direction.north => {
                    new.data = LoopPart{ .pipe_piece = NE, .x = x, .y = y };
                    loop.append(new);
                    try explorePipe(grid, x, y - 1, loop, alloc);
                },
                Direction.west => {
                    new.data = LoopPart{ .pipe_piece = WS, .x = x, .y = y };
                    loop.append(new);
                    try explorePipe(grid, x + 1, y, loop, alloc);
                },
                else => {
                    unreachable;
                },
            }
        },
        '-' => {
            std.debug.print("last dir-: {}\n", .{loop.last.?.data.pipe_piece.dir2});
            var new = try alloc.create(Node);
            switch (loop.last.?.data.pipe_piece.dir2) {
                Direction.east => {
                    new.data = LoopPart{ .pipe_piece = EE, .x = x, .y = y };
                    loop.append(new);
                    try explorePipe(grid, x, y - 1, loop, alloc);
                },
                Direction.west => {
                    new.data = LoopPart{ .pipe_piece = WW, .x = x, .y = y };
                    loop.append(new);
                    try explorePipe(grid, x, y + 1, loop, alloc);
                },
                else => {
                    unreachable;
                },
            }
        },
        '|' => {
            std.debug.print("last dir|: {}\n", .{loop.last.?.data.pipe_piece.dir2});
            var new = try alloc.create(Node);
            switch (loop.last.?.data.pipe_piece.dir2) {
                Direction.north => {
                    new.data = LoopPart{ .pipe_piece = NN, .x = x, .y = y };
                    loop.append(new);
                    try explorePipe(grid, x - 1, y, loop, alloc);
                },
                Direction.south => {
                    new.data = LoopPart{ .pipe_piece = SS, .x = x, .y = y };
                    loop.append(new);
                    try explorePipe(grid, x + 1, y, loop, alloc);
                },
                else => {
                    unreachable;
                },
            }
        },
        'S' => {
            return;
        },
        else => {
            unreachable;
        },
    }
}
fn printLoop(grid: anytype, loop: *DLL) void {
    var x: usize = 0;
    while (x < inputSize) : (x += 1) {
        var y: usize = 0;
        while (y < inputSize) : (y += 1) {
            var c = loop.first;
            while (c != null) {
                if (c.?.data.x == x and c.?.data.y == y) {
                    std.debug.print("{c}", .{grid[x][y]});
                    break;
                }
                c = c.?.next;
            } else {
                std.debug.print("{c}", .{grid[x][y]});
            }
        }
        std.debug.print("\n", .{});
    }
}

fn countEnclosed(gridd: [inputSize][]const u8, loop: *DLL) usize {
    var enclosed: usize = 0;

    //create mutable copy of gridd
    var grid: [inputSize][inputSize]u8 = undefined;
    for (0..inputSize) |i| {
        for (0..inputSize) |j| {
            grid[i][j] = gridd[i][j];
        }
    }

    //mark everything that is not part of the loop with O
    {
        var x: usize = 0;
        var y: usize = 0;
        while (x < inputSize) : (x += 1) {
            y = 0;
            while (y < inputSize) : (y += 1) {
                var c = loop.first;
                while (c != null) {
                    if (c.?.data.x == x and c.?.data.y == y) {
                        break;
                    }
                    c = c.?.next;
                } else {
                    grid[x][y] = 'O';
                }
            }
        }
    }
    //go clockwise through the loop and mark every O in marker dir up to the next loop intersection as X
    {
        var c = loop.first.?.next; //ignore start symbol since it has no .marker_dir

        while (c != null) {
            const mark_dir = c.?.data.pipe_piece.marker_dir;
            for (0..2) |m| {
                const mark = if (m == 0) mark_dir.a else mark_dir.b;
                std.debug.print("mark_dir: {}", .{mark});
                switch (mark) {
                    Direction.north => {
                        var x = c.?.data.x - 1;
                        var y = c.?.data.y;
                        std.debug.print(" x:{} y:{} \n", .{ x, y });
                        while (x > 0 and (grid[x][y] == 'O' or grid[x][y] == 'X')) : (x -= 1) {
                            grid[x][y] = 'X';
                        }
                    },
                    Direction.south => {
                        var x = c.?.data.x + 1;
                        var y = c.?.data.y;
                        std.debug.print(" x:{} y:{} \n", .{ x, y });
                        while (x < inputSize and (grid[x][y] == 'O' or grid[x][y] == 'X')) : (x += 1) {
                            grid[x][y] = 'X';
                        }
                    },
                    Direction.east => {
                        var x = c.?.data.x;
                        var y = c.?.data.y - 1;
                        std.debug.print(" x:{} y:{} \n", .{ x, y });
                        while (y > 0 and (grid[x][y] == 'O' or grid[x][y] == 'X')) : (y -= 1) {
                            grid[x][y] = 'X';
                        }
                    },
                    Direction.west => {
                        var x = c.?.data.x;
                        var y = c.?.data.y + 1;
                        std.debug.print(" x:{} y:{} \n", .{ x, y });
                        while (y < inputSize and (grid[x][y] == 'O' or grid[x][y] == 'X')) : (y += 1) {
                            grid[x][y] = 'X';
                        }
                    },
                }
            }
            c = c.?.next;
        }
    }

    for (0..inputSize) |x| {
        for (0..inputSize) |y| {
            if (grid[x][y] == 'X') enclosed += 1;
        }
    }

    printLoop(grid, loop);
    std.debug.print("enclosed: {}\n", .{enclosed});

    return enclosed;
}
