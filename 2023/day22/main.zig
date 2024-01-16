const std = @import("std");
const tokenize = std.mem.tokenize;
const Vec3 = @Vector(3, usize);
const Vec2 = @Vector(2, usize);
const Arr = std.ArrayList;
const ParsseInt = std.fmt.parseInt;
const sort = std.mem.sortUnstable;

const input = @embedFile("input.txt");
const HORIZONTAL_DIST = 10;

const Brick = struct {
    Vec3,
    Vec3,
};
fn lowerBrick(_: usize, lhs: Brick, rhs: Brick) bool {
    const lhsBottom = @min(lhs[0][2], lhs[1][2]);
    const rhsBottom = @min(rhs[0][2], rhs[1][2]);

    return lhsBottom < rhsBottom;
}

fn supportedBy(brick: Brick, bricks: *Arr(Brick), toIgnore: usize) ?Brick {
    if (brick[0][2] == 1 or brick[1][2] == 1) return brick;
    const brickXRange = .{ @min(brick[0][0], brick[1][0]), @max(brick[0][0], brick[1][0]) };
    const brickYRange = .{ @min(brick[0][1], brick[1][1]), @max(brick[0][1], brick[1][1]) };
    const brickBottom = @min(brick[0][2], brick[1][2]);
    for (bricks.items, 0..) |otherBrick, i| {
        if (@reduce(.And, brick[0] == otherBrick[0]) and @reduce(.And, brick[1] == otherBrick[1])) continue;
        if (i == toIgnore) continue;
        const otherBrickXRange = .{ @min(otherBrick[0][0], otherBrick[1][0]), @max(otherBrick[0][0], otherBrick[1][0]) };
        const otherBrickYRange = .{ @min(otherBrick[0][1], otherBrick[1][1]), @max(otherBrick[0][1], otherBrick[1][1]) };
        const otherBrickTop = @max(otherBrick[0][2], otherBrick[1][2]);
        if (
        //
        (brickXRange[0] <= otherBrickXRange[1] and
            brickXRange[1] >= otherBrickXRange[0]) and
            (brickYRange[0] <= otherBrickYRange[1] and
            brickYRange[1] >= otherBrickYRange[0]) and
            (brickBottom - 1 == otherBrickTop)) return otherBrick;
    }
    return null;
}

//applies gravity to bricks returns true if something changed
fn gravity(bricks: *Arr(Brick)) bool {
    var changed = false;
    var i: usize = 0;
    while (i < bricks.items.len) : (i += 1) {
        while (supportedBy(bricks.items[i], bricks, bricks.items.len) == null) {
            bricks.items[i][0][2] -= 1;
            bricks.items[i][1][2] -= 1;
            changed = true;
        }
    }
    return changed;
}

//simulates gravity without changing bricks arr if toDisintigrate(index in bricks arr) waa removed
//true if something would change without that brick
fn SimulateGravity(bricks: *Arr(Brick), toDisintigrate: usize) bool {
    var i: usize = 0;
    while (i < bricks.items.len) : (i += 1) {
        if (supportedBy(bricks.items[i], bricks, toDisintigrate) == null) {
            return true;
        }
    }
    return false;
}

fn countDisintirateable(bricks: *Arr(Brick)) usize {
    var disintigrateable: usize = 0;
    for (bricks.items, 0..) |brick, i| {
        _ = brick;
        if (SimulateGravity(bricks, i)) {
            // std.debug.print("Brick {}: {} cannot be Disintigrated!\n", .{ i, brick });
        } else {
            // std.debug.print("Brick {}: {} can be Disintigrated!\n", .{ i, brick });
            disintigrateable += 1;
        }
    }
    return disintigrateable;
}

fn printYZplane(bricks: *Arr(Brick)) void {
    for (0..HORIZONTAL_DIST) |ii| {
        if (ii == HORIZONTAL_DIST / 2) std.debug.print("Y", .{}) else std.debug.print(" ", .{});
    }
    std.debug.print("\n", .{});
    var i = bricks.items.len - 1;
    var currentHeight = @max(bricks.items[i][0][2], bricks.items[i][1][2]);
    while (currentHeight > 0) : (currentHeight -= 1) {
        for (0..HORIZONTAL_DIST) |ii| {
            for (bricks.items) |value| {
                if (currentHeight >= value[0][2] and currentHeight <= value[1][2]) {
                    if (@min(value[0][1], value[1][1]) <= ii and @max(value[1][1], value[0][1]) >= ii) {
                        std.debug.print("#", .{});
                        break;
                    }
                }
            } else {
                std.debug.print(".", .{});
            }
        }

        std.debug.print("  {}\n", .{currentHeight});
    }
    // std.debug.print("  {}\n", .{currentHeight});
}

fn printXZplane(bricks: *Arr(Brick)) void {
    for (0..HORIZONTAL_DIST) |ii| {
        if (ii == HORIZONTAL_DIST / 2) std.debug.print("X", .{}) else std.debug.print(" ", .{});
    }
    std.debug.print("\n", .{});
    var i = bricks.items.len - 1;
    var currentHeight = @max(bricks.items[i][0][2], bricks.items[i][1][2]);
    while (currentHeight > 0) : (currentHeight -= 1) {
        for (0..HORIZONTAL_DIST) |ii| {
            for (bricks.items) |value| {
                if (currentHeight >= value[0][2] and currentHeight <= value[1][2]) {
                    if (@min(value[0][0], value[1][0]) <= ii and @max(value[1][0], value[0][0]) >= ii) {
                        std.debug.print("#", .{});
                        break;
                    }
                }
            } else {
                std.debug.print(".", .{});
            }
        }

        std.debug.print("  {}\n", .{currentHeight});
    }
    // std.debug.print("  {}\n", .{currentHeight});
}
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const galloc = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(galloc);
    defer arena.deinit();
    const alloc = arena.allocator();

    var bricks = Arr(Brick).init(alloc);
    defer bricks.deinit();

    var it = tokenize(u8, input, "\n");
    while (it.next()) |tok| {
        var pointsIt = tokenize(u8, tok, "~,");
        const brick = Brick{
            Vec3{
                //
                try ParsseInt(usize, pointsIt.next().?, 10),
                try ParsseInt(usize, pointsIt.next().?, 10),
                try ParsseInt(usize, pointsIt.next().?, 10),
            },
            Vec3{
                //
                try ParsseInt(usize, pointsIt.next().?, 10),
                try ParsseInt(usize, pointsIt.next().?, 10),
                try ParsseInt(usize, pointsIt.next().?, 10),
            },
        };
        try bricks.append(brick);
    }

    var toSort = try bricks.toOwnedSlice();
    sort(Brick, toSort, @as(usize, 1), lowerBrick);
    try bricks.appendSlice(toSort);
    _ = gravity(&bricks);

    toSort = try bricks.toOwnedSlice();
    sort(Brick, toSort, @as(usize, 1), lowerBrick);
    bricks = Arr(Brick).fromOwnedSlice(alloc, toSort);

    // printXZplane(&bricks);
    // printYZplane(&bricks);
    //
    // for (bricks.items) |b| {
    //     std.debug.print("{}\n", .{b});
    // }
    const disintigratable = countDisintirateable(&bricks);
    std.debug.print("Disintigrateable: {}\n", .{disintigratable});
}
