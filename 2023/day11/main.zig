const std = @import("std");
const input = @embedFile("input.txt");
const inputSize = 140;

//
// ...#......
// .......#..
// #.........
// ..........
// ......#...
// .#........
// .........#
// ..........
// .......#..
// #...#.....
//
// rows and cols w/o galaxys(#) have to be expanded 2x
// number of pairs (binom.coefficient(n k))
// find sum of distance between all pairs
// distance: vec2 - vec1
//
// arrlist of vcs
//
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var galaxys = std.ArrayList(@Vector(2, i64)).init(alloc);
    defer galaxys.deinit();

    var map: [inputSize][]const u8 = undefined;

    {
        var it = std.mem.tokenize(u8, input, "\n");
        var i: usize = 0;
        while (it.next()) |tok| : (i += 1) {
            map[i] = tok;
        }
    }

    //expand empty rows and cols
    var rows_to_expand: [inputSize]bool = [1]bool{false} ** inputSize;
    var cols_to_expand: [inputSize]bool = [1]bool{false} ** inputSize;
    for (map, 0..) |m, i| {
        if (std.mem.eql(u8, "." ** inputSize, m)) rows_to_expand[i] = true;
        var col_all_empty = true;
        for (0..inputSize) |y| {
            if (map[y][i] != '.') col_all_empty = false;
        }
        cols_to_expand[i] = col_all_empty;
    }

    //new grid size is inputSize + rows_to_expand.count.true
    const expandedSizeW: usize = std.mem.count(bool, &cols_to_expand, &[1]bool{true}) + inputSize;
    const expandedSizeH: usize = std.mem.count(bool, &rows_to_expand, &[1]bool{true}) + inputSize;

    var expandedMap: [inputSize * 2][inputSize * 2]u8 = undefined;

    {
        var i: usize = 0;
        var ii: usize = 0;
        while (i < inputSize) {
            defer {
                ii += 1;
                i += 1;
            }
            var j: usize = 0;
            var jj: usize = 0;
            while (j < inputSize) {
                defer {
                    j += 1;
                    jj += 1;
                }
                if (cols_to_expand[j]) {
                    expandedMap[ii][jj] = '.';
                    jj += 1;
                }
                expandedMap[ii][jj] = map[i][j];
            }
            if (rows_to_expand[i]) {
                for (0..expandedSizeW) |x| {
                    expandedMap[ii][x] = '.';
                }
                ii += 1;
                for (0..expandedSizeW) |x| {
                    expandedMap[ii][x] = '.';
                }
            }
        }
    }
    for (expandedMap) |i| {
        std.debug.print("{s}\n", .{i[0..expandedSizeW]});
    }

    //find galaxys
    {
        var i: usize = 0;
        var j: usize = 0;
        while (i < expandedSizeH) : (i += 1) {
            j = 0;
            while (j < expandedSizeW) : (j += 1) {
                if (expandedMap[i][j] == '#') {
                    try galaxys.append(@Vector(2, i64){ @as(i64, @intCast(i)), @as(i64, @intCast(j)) });
                }
            }
        }
    }
    for (galaxys.items) |i| {
        std.debug.print("{},{}\n", .{ i[0], i[1] });
    }
    std.debug.print("part1: {}\n", .{try sum_distances(&galaxys)});
    {
        //part2

        galaxys.clearRetainingCapacity();
        var i: usize = 0;
        var ii: usize = 0;
        while (i < inputSize) {
            defer {
                i += 1;
                ii += 1;
            }
            var jj: usize = 0;
            var j: usize = 0;
            while (j < inputSize) {
                defer {
                    j += 1;
                    jj += 1;
                }
                if (cols_to_expand[j]) jj += 999_999;
                if (map[i][j] == '#') try galaxys.append(@Vector(2, i64){ @as(i64, @intCast(ii)), @as(i64, @intCast(jj)) });
            }
            if (rows_to_expand[i]) ii += 999_999;
        }
    }

    std.debug.print("part2: {}\n", .{try sum_distances(&galaxys)});
}
fn sum_distances(galaxys: *std.ArrayList(@Vector(2, i64))) !i64 {
    var sum: i64 = 0;
    {
        for (0..galaxys.items.len) |f| {
            for (f + 1..galaxys.items.len) |s| {
                sum += try std.math.absInt(galaxys.items[f][0] - galaxys.items[s][0]) + try std.math.absInt(galaxys.items[f][1] - galaxys.items[s][1]);
            }
        }
    }
    std.debug.print("sum_distances: {} \n", .{sum});
    return sum;
}
