const std = @import("std");
const Dijkstra = @import("Dijkstra.zig");
const input = @embedFile("input_small.txt");
const input_size = 13;

pub fn main() !void {
    var graph: [input_size][input_size]u8 = undefined;
    var it = std.mem.tokenize(u8, input, "\n");
    var i: usize = 0;
    while (it.next()) |tok| : (i += 1) {
        for (tok, 0..) |c, j| {
            graph[i][j] = c;
        }
    }

    const start = Dijkstra.Vec3{ 0, 0, 0 };
    const dest = Dijkstra.Vec3{ input_size - 1, input_size - 1, 0 };
    var path: [input_size][input_size]?Dijkstra.Vec3 = undefined;
    for (0..input_size) |x| {
        for (0..input_size) |y| {
            path[x][y] = null;
        }
    }

    try Dijkstra.Dijkstra(graph, start, dest, &path);

    Dijkstra.draw_path(graph, &path, dest);
}
