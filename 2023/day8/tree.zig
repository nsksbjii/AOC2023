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

    pub fn build_tree(self: *Node, productions: *std.StringHashMap([2][]const u8), nodes: *std.StringHashMap(Node)) !void {
        const prods = productions.get(self.name).?;
        std.debug.print("self.name: {s}\n", .{self.name});
        std.debug.print("prods: {s},{s}\n", .{ prods[0], prods[1] });
        std.debug.print("nodes: {any}\n", .{nodes.capacity()});

        if (self.depth > input_len) return;

        if (!(std.mem.eql(u8, self.name, prods[0]))) {
            var left = Node{ .name = prods[0], .depth = self.depth + 1 };
            var l = try nodes.getOrPut(left.name);
            if (!l.found_existing) {
                l.value_ptr.* = left;
                try l.value_ptr.build_tree(productions, nodes);
            }
            self.left = l.value_ptr;
        }
        if (!(std.mem.eql(u8, self.name, prods[1]))) {
            var right = Node{ .name = prods[1], .depth = self.depth + 1 };
            var r = try nodes.getOrPut(right.name);
            if (!r.found_existing) {
                r.value_ptr.* = right;
                try r.value_ptr.build_tree(productions, nodes);
            }
            self.right = r.value_ptr;
        }
    }

    pub fn ends_with_Z(self: *Node) bool {
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
                std.debug.print("{any}", .{s.name});
                s = s.go_left();
                std.debug.print("{any}", .{s.name});
            }
        } else {
            for (state) |*s| {
                std.debug.print("{any}", .{s.name});
                s.* = s.go_right().*;
                std.debug.print("{any}", .{s.name});
            }
        }
        for (state) |*s| {
            std.debug.print("{any}", .{s.name});
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

    //build_tree

    for (start_nodes.items) |*s| {
        try nodes.put(s.name, s.*);
        try s.*.build_tree(&productions, &nodes);
    }

    const p1 = try part2_single_thread(&start_nodes, lr_select);
    std.debug.print("{}\n", .{p1});
}
