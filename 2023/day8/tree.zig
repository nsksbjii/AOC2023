const std = @import("std");
//const input = @embedFile("input.txt");
const input = @embedFile("input_small_2.txt");
const input_len = 8;
// const input_len = 757;
//
const Node = struct {
    name: []const u8,
    left: ?*Node = null,
    right: ?*Node = null,
    depth: usize = 0,

    pub fn build_tree(self: *Node, productions: *std.StringHashMap([2][]const u8), nodes: *std.ArrayList(Node)) !usize {
        if (self.depth > input_len or std.mem.eql(u8, self.name, "---")) {
            return 1;
        }

        const prods = productions.get(self.name).?;
        // std.debug.print("self.name: {s}\n", .{self.name});
        // std.debug.print("prods: {s},{s}\n", .{ prods[0], prods[1] });
        // std.debug.print("nodes: {any}\n", .{nodes.items.len});
        // std.debug.print("depth: {}\n", .{self.depth});

        if (self.depth + 1 == input_len) {
            self.name = "---";
            return 1;
        }
        if (!(std.mem.eql(u8, self.name, prods[0]))) {
            var left = Node{ .name = prods[0], .depth = self.depth + 1 };
            var l = left;
            _ = try nodes.append(l);
            // std.debug.print("---{s}\n ", .{left.name});
            _ = try l.build_tree(productions, nodes);
            self.left = &l;
        }
        if (!(std.mem.eql(u8, self.name, prods[1]))) {
            var right = Node{ .name = prods[1], .depth = self.depth + 1 };
            var r = right;
            _ = try nodes.append(r);
            r.depth += 1;
            _ = try r.build_tree(productions, nodes);

            self.right = &r;
        }

        return 0;
    }

    pub fn ends_with_Z(self: *Node) bool {
        std.debug.print("self.name>>> {s}\n", .{self.name});
        return self.name[2] == 'Z';
    }

    pub fn go_left(self: *Node) *Node {
        return self.left orelse return self;
    }
    pub fn go_right(self: *Node) *Node {
        return self.right orelse return self;
    }
};

fn part2_single_thread(start: *std.ArrayList(Node), lr_select: []const u8) !usize {
    var steps: usize = 0;
    var state: []Node = try start.toOwnedSlice();
    while (true) : (steps += 1) {
        const p = @mod(steps, lr_select.len);
        if (lr_select[p] == 'L') {
            for (state) |*s| {
                std.debug.print("{s}\n", .{s.name});
                s.* = s.go_left().*;
                std.debug.print("{s}\n", .{s.name});
            }
        } else {
            for (state) |*s| {
                std.debug.print("{s}\n", .{s.name});
                s.* = s.go_right().*;
                std.debug.print("{s}\n", .{s.name});
            }
        }
        for (state) |*s| {
            std.debug.print("+++++++++++++{s}\n", .{s.name});
            if (!s.ends_with_Z()) break;
        } else {
            break;
        }
    }
    steps += 1;
    return steps;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var it = std.mem.tokenize(u8, input, "\n=(), ");

    var nodes = std.ArrayList(Node).init(alloc);
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

    //build_tree

    for (start_nodes.items) |*s| {
        std.debug.print("====={s}\n", .{s.name});
        _ = try s.build_tree(&productions, &nodes);
    }

    // for (start_nodes.items) |*s| {
    //     std.debug.print("====={s}\n", .{s.name});
    // }

    const p1 = try part2_single_thread(&start_nodes, lr_select);
    std.debug.print("{}\n", .{p1});
}
