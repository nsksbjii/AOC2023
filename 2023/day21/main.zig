const std = @import("std");

//tiles reachable from Start with n steps:
//--> all tiles with dist from start < n and tile.distFromStart % 2 == n %2
//->
//    Dijkstra algo to find all tiles with dist < n
//    filter mod(dist, 2) == mod(n,2)

const input = @embedFile("input.txt");
const INPUT_SIZE = 131;
const STEPS = 6;

const XY = struct { usize, usize };

const Plot = struct {
    dist: usize,
    visited: bool,
};
fn findMinINdex(distances: *[INPUT_SIZE][INPUT_SIZE]Plot) XY {
    var minX: usize = undefined;
    var minY: usize = undefined;
    var minDist: usize = 10000000;
    for (0..INPUT_SIZE) |x| {
        for (0..INPUT_SIZE) |y| {
            if (distances[x][y].dist < minDist and !distances[x][y].visited) {
                minDist = distances[x][y].dist;
                minX = x;
                minY = y;
            }
        }
    }
    return XY{ minX, minY };
}

//77865270  TO LOW
//gardenplots: cost 1
//rock cost INT_MAX
fn getNeighbours(current: XY) [4]XY {
    var N1: XY = undefined;
    var N2: XY = undefined;
    var N3: XY = undefined;
    var N4: XY = undefined;
    if (current[0] > 0) N1 = XY{ current[0] - 1, current[1] } else N1 = current;
    if (current[0] < INPUT_SIZE - 1) N2 = XY{ current[0] + 1, current[1] } else N2 = current;
    if (current[1] > 0) N3 = XY{ current[0], current[1] - 1 } else N3 = current;
    if (current[1] < INPUT_SIZE - 1) N4 = XY{ current[0], current[1] + 1 } else N4 = current;
    return [4]XY{ N1, N2, N3, N4 };
}

fn minPlotDistances(map: [INPUT_SIZE][INPUT_SIZE]u8, distances: *[INPUT_SIZE][INPUT_SIZE]Plot) void {

    //mark all distances with HIGH value exept for start which is 0
    //all rocks with EXTRAHIGH
    for (0..INPUT_SIZE) |x| {
        for (0..INPUT_SIZE) |y| {
            if (map[x][y] == '.') {
                distances[x][y].dist = 1000;
                distances[x][y].visited = false;
            }
            if (map[x][y] == '#') {
                distances[x][y].dist = 1000_000;

                distances[x][y].visited = true;
            }
            if (map[x][y] == 'S') {
                // std.debug.print("==S: {}, {}\n", .{ x, y });
                distances[x][y].dist = 0;
                distances[x][y].visited = false;
            }
        }
    }

    var currentXY = findMinINdex(distances);

    // std.debug.print("==MinIndex: {}, {}\n", .{ currentXY[0], currentXY[1] });
    while (distances[currentXY[0]][currentXY[1]].dist <= STEPS) {
        currentXY = findMinINdex(distances);
        var current = &distances[currentXY[0]][currentXY[1]];
        // std.debug.print("{} {}\n", .{ currentXY, current.dist });
        current.visited = true;

        var neighbours = getNeighbours(currentXY);
        for (neighbours) |neighbour| {
            if (distances[neighbour[0]][neighbour[1]].visited) continue;
            const newDist = current.dist + 1;
            if (newDist < distances[neighbour[0]][neighbour[1]].dist) {
                distances[neighbour[0]][neighbour[1]].dist = newDist;
            }
        }
    }
}

fn printReachable(distances: [INPUT_SIZE][INPUT_SIZE]Plot, map: [INPUT_SIZE][INPUT_SIZE]u8) void {
    var reachable: usize = 0;
    for (distances, 0..) |row, x| {
        for (row, 0..) |col, y| {
            // if (col.dist <= STEPS and @mod(STEPS, 2) == @mod(col.dist, 2)) {
            if (col.dist <= STEPS and @mod(STEPS, 2) == @mod(col.dist, 2)) {
                std.debug.print("O", .{});
                reachable += 1;
            } else {
                std.debug.print("{c}", .{map[x][y]});
            }
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("reachable: {}\n", .{reachable});
}
fn printDIstances(distances: [INPUT_SIZE][INPUT_SIZE]Plot) void {
    for (distances) |row| {
        for (row) |col| {
            std.debug.print("{} ", .{col.dist});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
}
pub fn main() !void {
    var map: [INPUT_SIZE][INPUT_SIZE]u8 = undefined;
    var distances: [INPUT_SIZE][INPUT_SIZE]Plot = undefined;

    var it = std.mem.tokenize(u8, input, "\n");
    var x: usize = 0;
    while (it.next()) |tok| : (x += 1) {
        var y: usize = 0;
        for (tok) |c| {
            defer y += 1;
            map[x][y] = c;
        }
    }

    minPlotDistances(map, &distances);
    printReachable(distances, map);
}
