const std = @import("std");
const SearchArr = std.ArrayList(SearchNode);

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
    prev: *Node,
};
fn init_nodes(nodes: *[][4][input_size][input_size]Node, map: *[input_size][input_size]u8) void {
    // std.debug.rint("initializing nodes\n", .{});
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
fn delete_SearchNode(seach_nodes: *SearchArr, delete_idx: usize) void {
    seach_nodes.items[delete_idx].row = seach_nodes.getLast().row;
    seach_nodes.items[delete_idx].col = seach_nodes.getLast().col;
    seach_nodes.items[delete_idx].currentDir = seach_nodes.getLast().currentDir;
    seach_nodes.items[delete_idx].streight_steps = seach_nodes.getLast().streight_steps;
    seach_nodes.items[delete_idx].node = seach_nodes.getLast().node;

    seach_nodes.items.len -= 1;
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
fn found_target(search_nodes: *SearchArr) isize {
    for (search_nodes.items) |i| {
        if (i.row == input_size - 1 and i.col == input_size - 1) return i.node.dist_from_source;
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
fn add_search_node(search_nodes: *SearchArr, nodes: *[][4][input_size][input_size]Node, path: *[input_size][input_size]u8, args: struct { usize, Direction, isize, isize, isize }) !usize {
    const streight_steps = args[0];
    const current_dir = args[1];
    const row = args[2];
    const col = args[3];
    const dist_from_source = args[4];

    // std.debug.print("Trying to add SearchNode:{any}\n", .{args});

    //TODO row and @as(usize,@intCast(col)) are isize and will crash if ever  <0
    if (row < 0 or
        row >= input_size or
        col < 0 or
        col >= input_size or
        streight_steps > 9 or
        nodes.*[streight_steps][@intFromEnum(current_dir)][@as(usize, @intCast(row))][@as(usize, @intCast(col))].visited) return search_nodes.items.len;
    // search_nodes[search_nodes.items.len].currentDir = current_dir;
    // search_nodes[search_nodes.items.len].row = row;
    // search_nodes[search_nodes.items.len].col = col;
    // search_nodes[search_nodes.items.len].node = &nodes[streight_steps][@intFromEnum(current_dir)][@as(usize, @intCast(row))][@as(usize, @intCast(col))];
    // search_nodes[search_nodes.items.len].node.visited = true;
    //
    // search_nodes[search_nodes.items.len].streight_steps = streight_steps;
    // search_nodes[search_nodes.items.len].node.dist_from_source = dist_from_source + search_nodes[search_nodes.items.len].node.cost;
    //

    try search_nodes.append(SearchNode{
        .currentDir = current_dir,
        .row = row,
        .col = col,
        .node = &nodes.*[streight_steps][@intFromEnum(current_dir)][@as(usize, @intCast(row))][@as(usize, @intCast(col))],
        .streight_steps = streight_steps,
    });
    var last = &search_nodes.getLast();
    last.*.node.visited = true;
    last.*.node.dist_from_source = dist_from_source + last.node.cost;

    // std.debug.print("Added SearchNode:{any}\n", .{args});

    add_to_path(path, row, col, current_dir);

    // print_path(path.*);
    return search_nodes.items.len;
}

fn get_next_SearchNode(search_node: *SearchNode, walking_dir: Go_Dir) ?struct { usize, Direction, isize, isize, isize } {
    // std.debug.print("findingnext search_node for: {} {} {}   -> {}\n", .{ search_node.row, search_node.col, search_node.currentDir, walking_dir });
    if (walking_dir == Go_Dir.STREIGHT) {
        switch (search_node.currentDir) {
            Direction.NORTH => {
                if (search_node.row > 0) {
                    const new_rowi = search_node.row + Dir2Index[@intFromEnum(search_node.currentDir)][@intFromEnum(walking_dir)];
                    if (new_rowi < 0) return null;
                    // const new_row = @as(usize, @intCast(new_rowi));
                    // const colu = @as(usize, @intCast(search_node.col));

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
                    // const colu = @as(usize, @intCast(search_node.col));
                    // const new_row = @as(usize, @intCast(new_rowi));
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
                    // std.debug.print("{}  {}  {}\n", .{ walking_dir, search_node.currentDir, new_coli });
                    if (new_coli >= input_size) unreachable;
                    // const rowu = @as(usize, @intCast(search_node.row));
                    // const new_col = @as(usize, @intCast(new_coli));
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
                    // const rowu = @as(usize, @intCast(search_node.row));
                    // const new_col = @as(usize, @intCast(new_coli));
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
                // const new_colu = if (new_coli >= 0 and new_coli < input_size) @as(usize, @intCast(new_coli)) else return null;
                // const rowu = @as(usize, @intCast(search_node.row));

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
                // const new_colu = if (new_coli >= 0 and new_coli < input_size) @as(usize, @intCast(new_coli)) else return null;
                // const rowu = @as(usize, @intCast(search_node.row));

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
                // const colu = @as(usize, @intCast(search_node.col));
                // const new_row = if (new_rowi >= 0 and new_rowi < input_size) @as(usize, @intCast(new_rowi)) else return null;
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
                // const new_row = if (new_rowi >= 0 and new_rowi < input_size) @as(usize, @intCast(new_rowi)) else return null;
                // const colu = @as(usize, @intCast(search_node.col));
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
fn find_closest_node(search_nodes: *SearchArr) usize {
    var min_dist: usize = 0;
    for (0..search_nodes.items.len) |i| {
        if (search_nodes.items[i].node.dist_from_source < search_nodes.items[min_dist].node.dist_from_source) {
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
    // if (@import("builtin").target.os.tag == .linux) {
    //     std.os.setrlimit(.STACK, .{
    //         .cur = 32 * 1024 * 1024,
    //         .max = 32 * 1024 * 1024,
    //     }) catch {
    //         @panic("unable to increase stack size");
    //     };
    // }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    var search_list = SearchArr.init(alloc);
    defer search_list.deinit();

    var sl = try alloc.alloc(SearchNode, MAX_SEARCH);
    defer alloc.free(sl);
    var sl_len = 0;
    _ = sl_len;

    var map: [input_size][input_size]u8 = undefined;
    var path: [input_size][input_size]u8 = undefined;
    // var searchNodes: [MAX_SEARCH]SearchNode = undefined;
    // var searchNodesCount: usize = 0;

    var nodes = try alloc.alloc([4][input_size][input_size]Node, 10);
    defer alloc.free(nodes);

    {
        //pqrse input[]
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
    try search_list.append(SearchNode{ .row = 0, .col = 0, .streight_steps = 0, .currentDir = Direction.EAST, .node = &nodes[0][@intFromEnum(Direction.EAST)][0][0] });

    init_path(&path);

    var min_dist: isize = 0;
    // var prev_node: *Node = searchNodes[0].node;
    while (found_target(&search_list) == 0) {
        const adj_idx = find_closest_node(&search_list);
        if (get_next_SearchNode(&search_list.items[adj_idx], Go_Dir.STREIGHT)) |go_STREIGTH| _ = try add_search_node(&search_list, &nodes, &path, go_STREIGTH);
        if (search_list.items[adj_idx].streight_steps > 2) {
            if (get_next_SearchNode(&search_list.items[adj_idx], Go_Dir.LEFT)) |go_LEFT| _ = try add_search_node(&search_list, &nodes, &path, go_LEFT);
            if (get_next_SearchNode(&search_list.items[adj_idx], Go_Dir.RIGHT)) |go_RIGHT| _ = try add_search_node(&search_list, &nodes, &path, go_RIGHT);
        }

        // std.debug.print("no new node added!!\n", .{});
        // prev_node = search_list.items[adj_idx].node;
        delete_SearchNode(&search_list, adj_idx);
    }

    min_dist = found_target(&search_list);

    print_path(path);

    std.debug.print("Part1: {}\n", .{min_dist});
}
