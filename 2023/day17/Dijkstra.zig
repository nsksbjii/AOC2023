const std = @import("std");
pub const Vec2 = @Vector(2, usize);
pub const Vec3 = @Vector(3, usize);
const Order = std.math.Order;
const PriorityQueue = std.PriorityQueue;

const input_size = 13;

pub fn Dijkstra(graph: [input_size][input_size]u8, start: Vec3, dest: Vec3, path: *[input_size][input_size]?Vec3) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var queue = PriorityQueue(Vec3, void, compareFn).init(alloc, {});
    defer queue.deinit();

    {
        var i: usize = 0;
        while (i < input_size) : (i += 1) {
            var j: usize = 0;
            while (j < input_size) : (j += 1) {
                var node = Vec3{ i, j, 0 };
                if (i != start[0] or j != start[1]) {
                    std.debug.print("sss\n", .{});
                    node[2] = input_size * input_size + i * j;
                }
                try queue.add(node);
            }
        }
    }

    {
        while (queue.count() > 0) {
            const current = queue.remove();
            std.debug.print("current: {}  \n", .{current});
            if (current[0] == dest[0] and current[1] == dest[1]) {
                path[dest[0]][dest[1]] = current;
                return;
            }

            draw_path(graph, path, current);
            var neighbour = get_neighbours(&queue, current);
            for (0..4) |x| {
                var n = neighbour[x];
                const none = Vec3{ 0, 0, 1000 };
                if (@reduce(.And, n == none)) continue;

                const new_dist = current[2] + try std.fmt.parseInt(u8, graph[n[0]][n[1] .. n[1] + 1], 10) + try streight_dist(path, current, n);
                std.debug.print("{} --- {}\n", .{ n, new_dist });
                if (new_dist < n[2]) {
                    // try queue.update(n, Vec3{ n[0], n[1], new_dist });
                    n[2] = new_dist;

                    if (n[0] == 1 and n[1] == 0) {
                        std.debug.print("overwriting path[1][0] with {}\n", .{current});
                    }
                    path[n[0]][n[1]] = current;
                    if (path[current[0]][current[1]]) |p| {
                        std.debug.print("{} << {}\n", .{ p, current });
                    } else {
                        std.debug.print("no prredecessor!\n", .{});
                    }
                    std.debug.print("-{}\n", .{n});
                    try queue.add(n);
                }
            }
        }
    }

    return error.NoPathFound;
}
fn compareFn(_: void, a: Vec3, b: Vec3) Order {
    const dA = a[2];
    const dB = b[2];
    return if (dA < dB) .lt else if (dA > dB) .gt else .eq; //smallest distance shoud have highest priority
    //

}

//TODO
fn streight_dist(prev: *[input_size][input_size]?Vec3, node: Vec3, next: Vec3) !usize {
    const prev1 = if (prev[node[0]][node[1]]) |p| p else return 0;
    const prev2 = if (prev[prev1[0]][prev1[1]]) |p| p else return 0;
    const prev3 = if (prev[prev2[0]][prev2[1]]) |p| p else return 0;

    if (prev3[1] + 1 == prev2[1] and prev2[1] + 1 == prev1[1] and prev1[1] + 1 == next[1]) return std.math.pow(usize, input_size, 3);
    if (prev3[0] + 1 == prev2[0] and prev2[0] + 1 == prev1[0] and prev1[0] + 1 == next[0]) return std.math.pow(usize, input_size, 3);
    return 0;
}
fn get_neighbours(q: *PriorityQueue(Vec3, void, compareFn), c: Vec3) [4]Vec3 {
    const n1x = if (c[0] < input_size - 1) c[0] + 1 else null;
    const n1y: ?usize = c[1];

    const n2x: ?usize = c[0];
    const n2y = if (c[1] < input_size - 1) c[1] + 1 else null;

    const n3x: ?usize = c[0];
    const n3y = if (c[1] > 0) c[1] - 1 else null;

    const n4x = if (c[0] > 0) c[0] - 1 else null;
    const n4y: ?usize = c[1];

    var neighbours: [4]Vec3 = undefined;
    for (&neighbours) |*n| {
        n.* = Vec3{ 0, 0, 1000 };
    }

    var qit = q.iterator();
    var i: usize = 0;
    while (qit.next()) |n| : (i += 1) {
        if (n[0] == n1x and n[1] == n1y) neighbours[0] = Vec3{ n1x.?, n1y.?, n[2] };
        if (n[0] == n2x and n[1] == n2y) neighbours[1] = Vec3{ n2x.?, n2y.?, n[2] };
        if (n[0] == n3x and n[1] == n3y) neighbours[2] = Vec3{ n3x.?, n3y.?, n[2] };
        if (n[0] == n4x and n[1] == n4y) neighbours[3] = Vec3{ n4x.?, n4y.?, n[2] };
    }
    return neighbours;
}

pub fn draw_path(graph: [input_size][input_size]u8, path: *[input_size][input_size]?Vec3, dest: Vec3) void {
    if (@reduce(.And, dest == Vec3{ 0, 0, 0 })) return;
    var g: [input_size][input_size]u8 = graph;
    var p: [input_size][input_size]?Vec3 = path.*;
    _ = p;
    var current = path[dest[0]][dest[1]].?;

    while (true) {
        if (current[0] == 0 and current[1] == 0) break;
        std.debug.print("xx{}\n", .{current});
        std.debug.print("xxxx{}\n", .{path[current[0]][current[1]].?});
        g[current[0]][current[1]] = '#';

        current = path[current[0]][current[1]].?;
    }
    for (0..input_size) |i| {
        for (0..input_size) |j| {
            std.debug.print("{c}", .{g[i][j]});
        }
        std.debug.print("\n", .{});
    }
}