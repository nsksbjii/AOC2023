const std = @import("std");
const input = @embedFile("input.txt");
// const input = @embedFile("input_small_2.txt");
// const input_len = 8;
const input_len = 757;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var it = std.mem.tokenize(u8, input, "\n=(), ");

    var productions = std.ArrayList(@Vector(3, u24)).init(alloc);
    defer productions.deinit();
    var start: @Vector(8, u24) = [1]u24{0} ** 8;

    const lr_select = it.next().?;

    const a_vec: @Vector(input_len, u8) = [1]u8{'A'} ** input_len;
    _ = a_vec;
    const z_vec: @Vector(input_len, u8) = [1]u8{'Z'} ** input_len;
    _ = z_vec;

    var start_vec_counter: usize = 0;
    for (0..input_len) |_| {
        const starts = it.next().?;
        const lefts = it.next().?;
        const rights = it.next().?;

        std.debug.print("{s} --- {s} --- {s}\n", .{ starts, lefts, rights });

        var starti: u24 = 0;
        starti |= starts[0];
        starti <<= 8;
        starti |= starts[1];
        starti <<= 8;
        starti |= starts[2];

        var lefti: u24 = 0;
        lefti |= lefts[0];
        lefti <<= 8;
        lefti |= lefts[1];
        lefti <<= 8;
        lefti |= lefts[2];

        var righti: u24 = 0;
        righti |= rights[0];
        righti <<= 8;
        righti |= rights[1];
        righti <<= 8;
        righti |= rights[2];

        const production = @Vector(3, u24){ starti, lefti, righti };
        if (starts[2] == 'A') {
            start[start_vec_counter] = starti;
            start_vec_counter += 1;
        }
        try productions.append(production);
    }

    var productions_slice = try productions.toOwnedSlice();

    std.mem.sortUnstable(@Vector(3, u24), productions_slice, {}, S.orderVECu24_sort);

    var step: usize = 0;
    while (true) : (step += 1) {
        std.debug.print("step: {}\n", .{step});
        const p = @mod(step, lr_select.len);
        for (0..8) |i| {
            std.debug.print("", .{});
            const idx = std.sort.binarySearch(@Vector(3, u24), start[i], productions_slice, {}, S.orderVECu24_search).?;
            start[i] = if (lr_select[p] == 'L') productions_slice[idx][1] else productions_slice[idx][2];
        }
    }
    std.debug.print("{}\n", .{step});
}
const S = struct {
    fn orderVECu24_sort(__: void, lhs: @Vector(3, u24), rhs: @Vector(3, u24)) bool {
        _ = __;
        return lhs[0] < rhs[0];
    }
    fn orderVECu24_search(__: void, key: u24, mid: u24) std.math.Order {
        _ = __;
        return std.math.order(key, mid[0]);
    }
};
