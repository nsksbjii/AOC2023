const std = @import("std");
const tokenize = std.mem.tokenize;
const split = std.mem.split;

const input = @embedFile("input.txt");
const max_line_len = 31;

const Arr = std.ArrayList;

fn transpose(in: Arr(u32), alloc: std.mem.Allocator) !Arr(u32) {
    const width: u32 = max_line_len;
    const height = in.items.len;

    var ret = Arr(u32).init(alloc);
    var i: u32 = 0;
    while (i < width) : (i += 1) {
        var j: u32 = 0;
        var col: u32 = 0;
        var col_mask = @bitReverse(@as(u32, 1) << @as(u5, @intCast(width - i)));
        while (j < height) : (j += 1) {
            if ((in.items[j] & col_mask) == 0) col <<= 1 else {
                col <<= 1;
                col |= @as(u32, 1);
            }
        }

        if (col != 0) try ret.insert(0, col) else break;
    }

    return ret;
}

fn find_reflection(in: Arr(u32)) u32 {
    var reflected = false;
    var idx: usize = 1;
    while (!reflected and idx < in.items.len) : (idx += 1) {
        reflected = true;
        var low = idx;
        var high = idx - 1;
        while (low > 0 and high < in.items.len - 1) {
            low -= 1;
            high += 1;
            if (in.items[low] != in.items[high]) {
                reflected = false;
                break;
            }
        }
        if (reflected) break;
    }
    if (reflected) return @as(u32, @intCast(idx)) else return 0;
}

fn off_by_one(a: u32, b: u32) bool {
    return @popCount(a ^ b) == 1;
}
fn find_reflection_part2(in: Arr(u32)) u32 {
    var found_smudge = false;
    var reflected = false;
    var idx: usize = 1;
    while (idx < in.items.len) : (idx += 1) {
        reflected = true;
        found_smudge = false;
        var low = idx;
        var high = idx - 1;
        while (low > 0 and high < in.items.len - 1) {
            low -= 1;
            high += 1;
            if (in.items[low] == in.items[high]) {
                continue;
            } else if (!found_smudge and off_by_one(in.items[low], in.items[high])) {
                found_smudge = true;
            } else {
                reflected = false;
                break;
            }
        }
        if (reflected and found_smudge) break;
    }
    if (reflected and found_smudge) return @as(u32, @intCast(idx)) else return 0;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var total1: u32 = 0;
    var total2: u32 = 0;
    var it = split(u8, input, "\n\n");

    while (it.next()) |grid| {
        var rows = Arr(u32).init(alloc);
        defer rows.deinit();

        var row_str = tokenize(u8, grid, "\n");
        while (row_str.next()) |tok| {
            var row: u32 = 0;
            // row |= (@as(u32, 1) << @as(u5, @intCast(tok.len)));
            for (tok, 1..) |value, i| {
                if (value == '#') row |= (@as(u32, 1) << @as(u5, @intCast(tok.len - i)));
                if (value == '.') row |= (@as(u32, 0) << @as(u5, @intCast(tok.len - i)));
            }
            // std.debug.print(" {s}\n", .{tok});

            // std.debug.print("{b}\n", .{row});
            try rows.append(row);
        }

        var cols = try transpose(rows, alloc);
        defer cols.deinit();
        var hor1 = find_reflection(rows);
        var hor2 = find_reflection_part2(rows);
        if (hor1 > 0) total1 += 100 * hor1 else total1 += find_reflection(cols);
        if (hor2 > 0) total2 += 100 * hor2 else total2 += find_reflection_part2(cols);
        // for (cols.items) |i| {
        //     std.debug.print("{b}\n", .{i.unmanaged.masks[0..i.unmanaged.bit_length]});
        // std.debug.print("\n\n\n", .{});
    }
    std.debug.print("total: {}\n", .{total1});
    std.debug.print("tota2: {}\n", .{total2});
}
