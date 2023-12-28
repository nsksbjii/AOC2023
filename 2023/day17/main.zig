const std = @import("std");

const input = @embedFile("input.txt");
const input_size = 141;
const MAX_SEARCH = 10000;

const Direction = enum {
    NORTH,
    EAST,
    SOUTH,
    WEST,
};
const Go_Dir = enum {
    LEFT,
    RIGHT,
    STREIGHT,
};
const Go_Dir2Dir: [4][3]Direction = .{
    .{ Direction.WEST, Direction.EAST, Direction.NORTH },
    .{ Direction.NORTH, Direction.SOUTH, Direction.EAST },
    .{ Direction.EAST, Direction.WEST, Direction.SOUTH },
    .{ Direction.SOUTH, Direction.NORTH, Direction.WEST },
};
const Dir2Index = [4][3]isize{ .{ -1, 1, -1 }, .{ -1, 1, 1 }, .{ 1, -1, 1 }, .{ 1, -1, -1 } };
const Node = struct {
    dist_from_source: isize,
    cost: isize,
    visited: bool,
};
fn init_nodes(nodes: *[][4][input_size][input_size]Node, map: *[input_size][input_size]u8) void {
    for (0..input_size) |i| {
        for (0..input_size) |j| {
            for (0..4) |d| {
                for (0..10) |s| {
                    nodes.*[s][d][i][j].cost = map[i][j];
                    nodes.*[s][d][i][j].dist_from_source = MAX_SEARCH;
                    nodes.*[s][d][i][j].visited = false;
                }
            }
        }
    }
}
const SearchNode = struct {
    row: isize,
    col: isize,
    currentDir: Direction,
    streight_steps: usize,
    node: *Node,
};

//overwrite search_nodes[to_delete_idx] with last elem of search_nodes
//decrement search_nodes.len
fn delete_SearchNode(seach_nodes: *[]SearchNode, search_nodes_len: *usize, delete_idx: usize) void {
    seach_nodes.*[delete_idx].row = seach_nodes.*[search_nodes_len.* - 1].row;
    seach_nodes.*[delete_idx].col = seach_nodes.*[search_nodes_len.* - 1].col;
    seach_nodes.*[delete_idx].currentDir = seach_nodes.*[search_nodes_len.* - 1].currentDir;
    seach_nodes.*[delete_idx].streight_steps = seach_nodes.*[search_nodes_len.* - 1].streight_steps;
    seach_nodes.*[delete_idx].node = seach_nodes.*[search_nodes_len.* - 1].node;

    search_nodes_len.* -= 1;
}

fn init_path(path: *[input_size][input_size]u8) void {
    // std.debug.print("initializing path\n", .{});
    for (0..input_size) |i| {
        for (0..input_size) |j| {
            path[i][j] = '.';
        }
    }
    return;
}

//if target node is in searchNodes return dist from start else 0
fn found_target(search_nodes: *[]SearchNode, search_nodes_len: usize) isize {
    for (0..search_nodes_len) |i| {
        if (search_nodes.*[i].row == input_size - 1 and search_nodes.*[i].col == input_size - 1) return search_nodes.*[i].node.dist_from_source;
    }
    return 0;
}

fn add_to_path(path: *[input_size][input_size]u8, rowi: isize, coli: isize, dir: Direction) void {
    const row = @as(usize, @intCast(rowi));
    const col = @as(usize, @intCast(coli));
    switch (dir) {
        Direction.NORTH => {
            path[row][col] = '^';
        },
        Direction.EAST => {
            path[row][col] = '>';
        },
        Direction.SOUTH => {
            path[row][col] = 'v';
        },
        Direction.WEST => {
            path[row][col] = '<';
        },
    }
}

//add element to search_nodes if it is valid; valid if:
//-> new elem is inside grid
//-> new elem is not 4th step in same Direction
//-> now elem has not been visited
//returns search_nodes_len or search_nodes_len +1 if valid
fn add_search_node(search_nodes: *[]SearchNode, search_nodes_len: *usize, nodes: *[][4][input_size][input_size]Node, path: *[input_size][input_size]u8, args: struct { usize, Direction, isize, isize, isize }) usize {
    const streight_steps = args[0];
    const current_dir = args[1];
    const row = args[2];
    const col = args[3];
    const dist_from_source = args[4];

    if (row < 0 or
        row >= input_size or
        col < 0 or
        col >= input_size or
        streight_steps > 9 or
        nodes.*[streight_steps][@intFromEnum(current_dir)][@as(usize, @intCast(row))][@as(usize, @intCast(col))].visited) return search_nodes_len.*;
    search_nodes.*[search_nodes_len.*].currentDir = current_dir;
    search_nodes.*[search_nodes_len.*].row = row;
    search_nodes.*[search_nodes_len.*].col = col;
    search_nodes.*[search_nodes_len.*].streight_steps = streight_steps;

    search_nodes.*[search_nodes_len.*].node = &nodes.*[streight_steps][@intFromEnum(current_dir)][@as(usize, @intCast(row))][@as(usize, @intCast(col))];
    search_nodes.*[search_nodes_len.*].node.visited = true;

    search_nodes.*[search_nodes_len.*].node.dist_from_source = dist_from_source + search_nodes.*[search_nodes_len.*].node.cost;

    search_nodes_len.* += 1;

    add_to_path(path, row, col, current_dir);

    return search_nodes_len.*;
}

fn get_next_SearchNode(search_node: *SearchNode, walking_dir: Go_Dir) ?struct { usize, Direction, isize, isize, isize } {
    if (walking_dir == Go_Dir.STREIGHT) {
        switch (search_node.currentDir) {
            Direction.NORTH => {
                if (search_node.row > 0) {
                    const new_rowi = search_node.row + Dir2Index[@intFromEnum(search_node.currentDir)][@intFromEnum(walking_dir)];
                    if (new_rowi < 0) return null;

                    return .{
                        search_node.streight_steps + 1,
                        //
                        Go_Dir2Dir[@intFromEnum(search_node.currentDir)][@intFromEnum(walking_dir)],
                        //
                        new_rowi,
                        //
                        search_node.col,
                        //
                        search_node.node.dist_from_source,
                    };
                }
            },
            Direction.SOUTH => {
                if (search_node.row < input_size - 1) {
                    const new_rowi = search_node.row + Dir2Index[@intFromEnum(search_node.currentDir)][@intFromEnum(walking_dir)];
                    if (new_rowi >= input_size) unreachable;
                    return .{
                        search_node.streight_steps + 1,
                        //
                        Go_Dir2Dir[@intFromEnum(search_node.currentDir)][@intFromEnum(walking_dir)],
                        //
                        new_rowi,

                        //
                        search_node.col,
                        //
                        search_node.node.dist_from_source,
                    };
                }
            },
            Direction.EAST => {
                if (search_node.col < input_size - 1) {
                    const new_coli = search_node.col + Dir2Index[@intFromEnum(search_node.currentDir)][@intFromEnum(walking_dir)];
                    if (new_coli >= input_size) unreachable;
                    return .{
                        search_node.streight_steps + 1,
                        //
                        Go_Dir2Dir[@intFromEnum(search_node.currentDir)][@intFromEnum(walking_dir)],
                        //
                        search_node.row,
                        //
                        new_coli,
                        //
                        search_node.node.dist_from_source,
                    };
                }
            },

            Direction.WEST => {
                if (search_node.col > 0) {
                    const new_coli = search_node.col + Dir2Index[@intFromEnum(search_node.currentDir)][@intFromEnum(walking_dir)];
                    if (new_coli < 0) unreachable;
                    return .{
                        search_node.streight_steps + 1,
                        //
                        Go_Dir2Dir[@intFromEnum(search_node.currentDir)][@intFromEnum(walking_dir)],
                        //
                        search_node.row,
                        //
                        new_coli,
                        //
                        search_node.node.dist_from_source,
                    };
                }
            },
        }
    } else {
        switch (search_node.currentDir) {
            Direction.NORTH => {
                const new_coli = search_node.col + Dir2Index[@intFromEnum(search_node.currentDir)][@intFromEnum(walking_dir)];

                return .{
                    0,
                    //
                    Go_Dir2Dir[@intFromEnum(search_node.currentDir)][@intFromEnum(walking_dir)],
                    //
                    search_node.row,
                    //
                    new_coli,
                    //
                    search_node.node.dist_from_source,
                };
            },
            Direction.SOUTH => {
                const new_coli = search_node.col + Dir2Index[@intFromEnum(search_node.currentDir)][@intFromEnum(walking_dir)];

                return .{
                    0,
                    //
                    Go_Dir2Dir[@intFromEnum(search_node.currentDir)][@intFromEnum(walking_dir)],
                    //
                    search_node.row,

                    //
                    new_coli,

                    //
                    search_node.node.dist_from_source,
                };
            },
            Direction.EAST => {
                const new_rowi = search_node.row + Dir2Index[@intFromEnum(search_node.currentDir)][@intFromEnum(walking_dir)];
                return .{
                    0,
                    //
                    Go_Dir2Dir[@intFromEnum(search_node.currentDir)][@intFromEnum(walking_dir)],
                    //
                    new_rowi,
                    //
                    search_node.col,
                    //
                    search_node.node.dist_from_source,
                };
            },

            Direction.WEST => {
                const new_rowi = search_node.row + Dir2Index[@intFromEnum(search_node.currentDir)][@intFromEnum(walking_dir)];
                return .{
                    0,
                    //
                    Go_Dir2Dir[@intFromEnum(search_node.currentDir)][@intFromEnum(walking_dir)],
                    //
                    new_rowi,
                    //
                    search_node.col,
                    //
                    search_node.node.dist_from_source,
                };
            },
        }
    }

    return null;
}

//return index of current closest node to source
fn find_closest_node(search_nodes: *[]SearchNode, search_nodes_len: usize) usize {
    var min_dist: usize = 0;
    for (0..search_nodes_len) |i| {
        if (search_nodes.*[i].node.dist_from_source < search_nodes.*[min_dist].node.dist_from_source) {
            min_dist = i;
        }
    }
    return min_dist;
}

fn print_path(path: [input_size][input_size]u8) void {
    for (0..input_size) |i| {
        for (0..input_size) |j| {
            std.debug.print("{c}", .{path[i][j]});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
}
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var sl = try alloc.alloc(SearchNode, MAX_SEARCH); //stack is to small
    defer alloc.free(sl);
    var sl_len: usize = 0;

    var map: [input_size][input_size]u8 = undefined;
    var path: [input_size][input_size]u8 = undefined;

    var nodes = try alloc.alloc([4][input_size][input_size]Node, 10); //stack is to small so it has to be on heap
    defer alloc.free(nodes);

    {
        var i: usize = 0;
        var it = std.mem.tokenize(u8, input, "\n");
        while (it.next()) |tok| : (i += 1) {
            for (tok, 0..) |t, j| {
                map[i][j] = t - '0';
            }
        }
    }
    init_nodes(&nodes, &map);
    nodes[0][@intFromEnum(Direction.EAST)][0][0].cost = 0;
    nodes[0][@intFromEnum(Direction.EAST)][0][0].visited = true;
    nodes[0][@intFromEnum(Direction.EAST)][0][0].dist_from_source = 0;
    sl[sl_len] = SearchNode{ .row = 0, .col = 0, .streight_steps = 0, .currentDir = Direction.EAST, .node = &nodes[0][@intFromEnum(Direction.EAST)][0][0] };
    sl_len += 1;

    init_path(&path);

    var min_dist: isize = 0;
    while (found_target(&sl, sl_len) == 0) {
        const adj_idx = find_closest_node(&sl, sl_len);
        if (get_next_SearchNode(&sl[adj_idx], Go_Dir.STREIGHT)) |go_STREIGTH| _ = add_search_node(&sl, &sl_len, &nodes, &path, go_STREIGTH);
        if (sl[adj_idx].streight_steps > 2) {
            if (get_next_SearchNode(&sl[adj_idx], Go_Dir.LEFT)) |go_LEFT| _ = add_search_node(&sl, &sl_len, &nodes, &path, go_LEFT);
            if (get_next_SearchNode(&sl[adj_idx], Go_Dir.RIGHT)) |go_RIGHT| _ = add_search_node(&sl, &sl_len, &nodes, &path, go_RIGHT);
        }
        delete_SearchNode(&sl, &sl_len, adj_idx);
    }

    min_dist = found_target(&sl, sl_len);
    std.debug.print("Part2: {}\n", .{min_dist});
}
