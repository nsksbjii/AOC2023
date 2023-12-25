const std = @import("std");
// const input = @embedFile("input_small_2.txt");
const input = @embedFile("input.txt");
// const input_len = 8;
// const input_len = 757;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const alloc = gpa.allocator();
const Node = struct {
    name: []const u8,
    left: ?*Node = null,
    right: ?*Node = null,
    depth: usize = 0,

    pub fn build_tree(productions: *std.StringHashMap([2][]const u8), nodes: *std.StringHashMap(Node)) !usize {

        //create alll start?nodes
        // for (productions.items) |i|:
        //
        var prod_it = productions.iterator();
        while (prod_it.next()) |p| {
            // std.debug.print("{s}, {s}\n", .{ p[0], p[1] });
            try nodes.put(p.key_ptr.*, Node{ .name = p.key_ptr.* });
        }

        var node_it = nodes.iterator();
        while (node_it.next()) |*n| {
            var p = productions.get(n.key_ptr.*).?;
            // std.debug.print("{s}\n", .{p[0]});
            n.value_ptr.left = nodes.getPtr(p[0]);
            n.value_ptr.right = nodes.getPtr(p[1]);
        }
        return 0;
    }

    pub fn ends_with_Z(self: *Node) bool {
        // std.debug.print("self.name>>> {s}\n", .{self.name});
        return self.name[2] == 'Z';
    }

    pub fn go_left(self: *Node) ?*Node {
        return self.left;
    }
    pub fn go_right(self: *Node) ?*Node {
        return self.right;
    }
};

fn part2_single_thread(start: *std.ArrayList(Node), lr_select: []const u8, nodes: *std.StringHashMap(Node), prpds: *std.StringHashMap([2][]const u8)) !usize {

    //build tree
    //
    _ = try Node.build_tree(prpds, nodes);

    // for (start.items) |i|
    var steps: usize = 0;
    var state = std.ArrayList(*Node).init(alloc);
    defer state.deinit();

    for (start.items) |i| {
        try state.append(nodes.getPtr(i.name).?);
    }
    while (true) : (steps += 1) {
        if (@mod(steps, 1_000_000_000) == 0) std.debug.print("{}\n", .{steps});
        const p = @mod(steps, lr_select.len);
        var all_z = true;
        for (state.items, 0..) |sa, s| {
            // std.debug.print("++{s}\n", .{sa.name});
            // if (state.items[s].ends_with_Z()) continue;
            if (lr_select[p] == 'L') {
                state.items[s] = sa.go_left().?;
                // std.debug.print("{s}\n", .{state.items[s].name});
            } else {
                state.items[s] = sa.go_right().?;
            }
            if (!state.items[s].ends_with_Z()) {
                all_z = false;
            } else {
                // std.debug.print("{s} --> {s} in {} steps\n", .{ start.items[s].name, state.items[s].name, steps + 1 });
                state.items[s].depth = steps + 1;
            }
        }

        if (all_z) break;
    }

    var depths = std.ArrayList(usize).init(alloc);
    defer depths.deinit();

    for (state.items) |i| {
        try depths.append(i.depth);
    }
    const depths_start = try depths.clone();
    defer depths_start.deinit();

    //find gcd
    //sort depths
    var x = try depths.toOwnedSlice();
    defer alloc.free(x);

    var lcm: u128 = 0;
    _ = lcm;
    std.mem.sortUnstable(usize, x, {}, std.sort.asc(usize));
    {
        var i: usize = 0;
        while (i < x.len - 1) : (i += 1) {
            var a = x[i];
            var b = x[i + 1];
            std.debug.print("A: {}    B:{}\n", .{ a, b });
            const ab = a * b;
            _ = ab;

            var gcd = while (true) {
                if (a == b) break a;
                if (a < b) b -= a;
                if (b < a) a -= b;
            };
            std.debug.print("gsd: {}\n", .{gcd});
            x[i + 1] = gcd;

            depths_start.items[i + 1] = (depths_start.items[i] * depths_start.items[i + 1]) / gcd;

            std.debug.print("lcm: {}\n", .{depths_start.items[i + 1]});
        }
    }

    // outer: while (true) {
    //     var all_equal = true;
    //     var current_min: usize = 0xffffffff;
    //     var min_idx: usize = 0;
    //     for (depths.items, 0..) |i, idx| {
    //         if (i < current_min) {
    //             current_min = i;
    //             min_idx = idx;
    //         }
    //         if (idx < depths.items.len - 1) {
    //             if (depths.items[idx] != depths.items[idx + 1]) all_equal = false;
    //         }
    //     }
    //     if (all_equal) {
    //         lcm = depths.items[0];
    //         break :outer;
    //     }
    //     if (@mod(depths.items[min_idx], 100_000_000) == 0) std.debug.print("{}\n", .{depths.items[min_idx]});
    //     depths.items[min_idx] += depths_start.items[min_idx];
    // }
    return depths_start.items[depths_start.items.len - 1];
}

pub fn main() !void {
    defer _ = gpa.deinit();
    var it = std.mem.tokenize(u8, input, "\n=(), ");

    var nodes = std.StringHashMap(Node).init(alloc);
    defer nodes.deinit();
    const lr_select = it.next().?;

    var productions = std.StringHashMap([2][]const u8).init(alloc);
    defer productions.deinit();

    var start_nodes = std.ArrayList(Node).init(alloc);
    defer start_nodes.deinit();

    //genrate hash map
    //find everything that ends with A
    while (it.next()) |tok| {
        std.debug.print("{s}", .{tok});
        const k = tok;
        const a = [2][]const u8{ it.next().?, it.next().? };
        try productions.put(k, a);
        std.debug.print("  {s}, {s}\n", .{ a[0], a[1] });
        if (k[2] == 'A') try start_nodes.append(Node{ .name = k });
    }

    // std.debug.print("{any}", .{productions});

    // for (start_nodes.items) |*s| {
    //     std.debug.print("====={s}\n", .{s.name});
    // }

    const p1 = try part2_single_thread(&start_nodes, lr_select, &nodes, &productions);
    std.debug.print("{}\n", .{p1});
}
