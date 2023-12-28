const std = @import("std");

const tokenize = std.mem.tokenize;
const Vec = std.ArrayList;
const Vec2 = @Vector(2, isize);

const input = @embedFile("input.txt");

const DigInstruction = struct {
    dir: []const u8,
    dist: isize,
    color: []const u8,
};
//dir lookup table  directions part 2
const part2_dir = [4][]const u8{ "R", "D", "L", "U" };

const InstructionSet = Vec(DigInstruction);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const gpa_alloc = gpa.allocator();

    var arena = std.heap.ArenaAllocator.init(gpa_alloc);
    const alloc = arena.allocator();
    defer arena.deinit();

    var digg_list = InstructionSet.init(alloc);
    var digg_list2 = InstructionSet.init(alloc);

    var it = tokenize(u8, input, "\n");

    while (it.next()) |tok| {
        var instruction_string = tokenize(u8, tok, " (#)");
        const dir = instruction_string.next().?;
        const dist = try std.fmt.parseInt(isize, instruction_string.next().?, 10);
        const color = instruction_string.next().?;

        try digg_list.append(DigInstruction{ .dir = dir, .dist = dist, .color = color });
        try digg_list2.append(DigInstruction{ .dir = part2_dir[color[5] - '0'], .dist = try std.fmt.parseInt(isize, color[0..5], 16), .color = color });
    }

    var vertices = try alloc.alloc(Vec2, digg_list.items.len);
    var x: isize = 0;
    var y: isize = 0;
    for (digg_list.items, 0..) |instr, i| {
        switch (instr.dir[0]) {
            'U' => {
                x += instr.dist + 0;
                vertices[i] = Vec2{ x, y };
            },

            'D' => {
                x -= instr.dist - 0;
                vertices[i] = Vec2{ x, y };
            },

            'R' => {
                y += instr.dist - 0;
                vertices[i] = Vec2{ x, y };
            },

            'L' => {
                y -= instr.dist + 0;
                vertices[i] = Vec2{ x, y };
            },
            else => {
                unreachable;
            },
        }
    }

    var vertices2 = try alloc.alloc(Vec2, digg_list2.items.len);
    var x2: isize = 0;
    var y2: isize = 0;
    for (digg_list2.items, 0..) |instr, i| {
        switch (instr.dir[0]) {
            'U' => {
                x2 += instr.dist + 0;
                vertices2[i] = Vec2{ x2, y2 };
            },

            'D' => {
                x2 -= instr.dist - 0;
                vertices2[i] = Vec2{ x2, y2 };
            },

            'R' => {
                y2 += instr.dist - 0;
                vertices2[i] = Vec2{ x2, y2 };
            },

            'L' => {
                y2 -= instr.dist + 0;
                vertices2[i] = Vec2{ x2, y2 };
            },
            else => {
                unreachable;
            },
        }
    }

    //Gauss Area Formula (sholelace formula)
    const area = shoelace(vertices);

    //Picks Theorem
    // A = i + (b/2)  -1
    // A arena of polygon
    // i #points enclosed by polygon
    // b egde + vertex points

    var b = blk: {
        var acc: isize = 0;
        for (digg_list.items) |i| {
            acc += i.dist;
        }
        break :blk acc;
    };

    // i = A - b/2 + 1;
    const i = area - @divTrunc(b, 2) + 1;
    std.debug.print("part1: {d}\n", .{i + b});

    const area2 = shoelace(vertices2);
    var bb = blk: {
        var acc: isize = 0;
        for (digg_list2.items) |j| {
            acc += j.dist;
        }
        break :blk acc;
    };
    const ii = area2 - @divTrunc(bb, 2) + 1;
    std.debug.print("part2: {d}\n", .{ii + bb});
}
//sholaceformula (gauss area formula)
fn shoelace(vecs: []Vec2) isize {
    var TwoA: isize = 0;
    for (0..vecs.len - 1) |i| {
        TwoA += determinat2x2(vecs[i], vecs[i + 1]);
    }
    TwoA += determinat2x2(vecs[vecs.len - 1], vecs[0]);

    return @divTrunc(TwoA, 2);
}

fn determinat2x2(v1: Vec2, v2: Vec2) isize {
    return v1[0] * v2[1] - v1[1] * v2[0];
}
