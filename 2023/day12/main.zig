const std = @import("std");
const input = @embedFile("input.txt");
const input_len = 1000;
const max_line_len = 64;
const BA = std.BoundedArray(u8, max_line_len);
const BA5 = std.BoundedArray(u8, max_line_len * 5);

const Arr = std.ArrayList;
const tokenize = std.mem.tokenize;
const count = std.mem.count;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var left = Arr(BA).init(alloc);
    var right = Arr(BA).init(alloc);
    defer left.deinit();
    defer right.deinit();

    var it = tokenize(u8, input, "\n");
    while (it.next()) |tok| {
        var l = tokenize(u8, tok, " ");
        const line_in = l.next().?;
        const backup_instructions = l.next().?;
        var b_tok = tokenize(u8, backup_instructions, ",");
        var rl = try BA.init(0);
        while (b_tok.next()) |r| {
            try rl.append(try std.fmt.parseInt(u8, r, 10));
        }
        var line = try BA.init(line_in.len);
        for (0..line_in.len) |i| {
            line.set(i, line_in[i]);
        }
        try left.append(line);
        try right.append(rl);
    }

    var cache = std.AutoHashMap(u64, usize).init(alloc); //StringHashMap causes key collisions!

    defer cache.deinit();

    var total: usize = 0;
    var total2: usize = 0;
    for (0..left.items.len) |i| {
        var l_part2 = try BA5.init(0);
        var r_part2 = try BA5.init(0);
        var c = try find_combinations(left.items[i].slice(), right.items[i].slice(), &cache);

        total += c;

        for (0..5) |j| {
            try l_part2.appendSlice(left.items[i].slice());
            try r_part2.appendSlice(right.items[i].slice());
            if (j < 4) try l_part2.append('?');
        }
        var cc = try find_combinations(l_part2.slice(), r_part2.slice(), &cache);
        cache.clearRetainingCapacity();
        total2 += cc;
    }
    std.debug.print("part1: {}\n", .{total});
    std.debug.print("part2: {}\n", .{total2});
}

fn find_combinations(left: []u8, right: []u8, cache: *std.AutoHashMap(u64, usize)) !usize {
    if (left.len == 0) {
        return if (right.len == 0) 1 else 0;
    }
    if (right.len == 0) {
        return if (std.mem.count(u8, left, "#") >= 1) 0 else 1;
    }
    var key: u64 = undefined; //using StringHashMap with concat(left,right) causes key collisions
    key = std.hash.Wyhash.hash(0, left);
    key = std.hash.Wyhash.hash(key, right);

    const cached = cache.get(key);
    if (cached) |c| return c;

    var result: usize = 0;

    if (left[0] == '.' or left[0] == '?') {
        result += try find_combinations(left[1..], right, cache);
    }
    if (left[0] == '#' or left[0] == '?') {
        if (right[0] < left.len and count(u8, left[0..right[0]], ".") == 0 and (right[0] == left.len or left[right[0]] != '#')) {
            result += try find_combinations(left[right[0] + 1 ..], right[1..], cache);
        } else if (right[0] <= left.len and count(u8, left[0..right[0]], ".") == 0 and (right[0] == left.len or left[right[0]] != '#')) {
            result += try find_combinations(left[right[0]..], right[1..], cache);
        }
    }

    try cache.put(key, result);
    return result;
}
