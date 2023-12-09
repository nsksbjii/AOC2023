const std = @import("std");
const input = @embedFile("input.txt");
// const input = @embedFile("input_small_2.txt");
// const input_len = 8;
const input_len = 757;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    {
        var productions = std.StringHashMap([2][]const u8).init(alloc);
        defer productions.deinit();

        var it = std.mem.tokenize(u8, input, "\n=(), ");
        const lrpattern = it.next().?;
        _ = lrpattern;
        while (it.next()) |tok| {
            const k = tok;
            const a = [2][]const u8{ it.next().?, it.next().? };
            try productions.put(k, a);
        }

        // {
        //     var step: usize = 0;
        //     var start: []const u8 = "AAA";
        //     while (true) : (step += 1) {
        //         // std.debug.print("{s} -->", .{start});
        //         const p = @mod(step, lrpattern.len);
        //         const production = productions.get(start).?;
        //         start = if (lrpattern[p] == 'L') production[0] else production[1];
        //
        //         // std.debug.print("{s}  {s} {}\n", .{ start, lrpattern[p .. p + 1], p });
        //         if (std.mem.eql(u8, start, "ZZZ")) break;
        //     }
        //     step += 1;
        //
        //     std.debug.print("steps: {}\n", .{step});
        // }
    }

    {
        var it = std.mem.tokenize(u8, input, "\n=(), ");
        var start: @Vector(input_len, u24) = [1]u24{0} ** input_len;
        var left: @Vector(input_len, u24) = [1]u24{0} ** input_len;
        var right: @Vector(input_len, u24) = [1]u24{0} ** input_len;
        const a_vec: @Vector(input_len, u8) = [1]u8{'A'} ** input_len;
        const z_vec: @Vector(input_len, u8) = [1]u8{'Z'} ** input_len;
        const last_byte: @Vector(input_len, u24) = [1]u24{0x0000ff} ** input_len;
        const first_byte: @Vector(input_len, u24) = [1]u24{0xffff00} ** input_len;
        _ = first_byte;
        const all_zero: @Vector(input_len, u24) = @splat(0);

        const lr_select = it.next().?;

        for (0..input_len) |i| {
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

            start[i] = starti;
            left[i] = lefti;
            right[i] = righti;
        }

        // std.debug.print("{b}\n", .{last_byte[0]});

        // var state = (start | last_byte) ^ last_byte ^ ~a_vec;;;;
        var state = start & last_byte | a_vec ^ a_vec;
        // std.debug.print("{x}\n", .{start});
        // std.debug.print("{x}\n", .{state});
        // std.debug.print("a_vec: {b}\n", .{a_vec});
        // std.debug.print("z_vec: {b}\n", .{z_vec});
        //
        // std.debug.print("{x}\n", .{start});
        // std.debug.print("{x}\n", .{left});
        // std.debug.print("{x}\n", .{right});
        var step: usize = 0;
        while (true) : (step += 1) {
            std.debug.print("{}\n", .{step});
            const p = @mod(step, lr_select.len);
            // std.debug.print("{x} {c} {}\n", .{ state, lr_select[p], p });
            if (lr_select[p] == 'L') {
                if (step == 0) {
                    // std.debug.print("==state: {}\n startt: {}\n", .{ state, start });
                    // std.debug.print("--0{x}\n", .{state});
                    state = @select(u24, state != all_zero, all_zero, left);
                    // std.debug.print(">>>state: {}\n startt: {}\n", .{ state, start });
                } else {
                    // std.debug.print("state: {} startt: {}\n", .{ state, start });
                    // std.debug.print("--1{x}\n", .{state});
                    for (0..input_len) |ci| {
                        state[std.simd.firstIndexOfValue(start, state[ci]).?] = state[ci];
                    }
                    state = @select(u24, state == start, start, all_zero);
                    // std.debug.print("--2{x}\n", .{state});
                    // std.debug.print("---LLLL--{x}\n", .{left});
                    state = @select(u24, state == all_zero, all_zero, left);
                    // std.debug.print("--3{x}\n", .{state});
                }
            } else {
                if (step == 0) {
                    // std.debug.print("---R-0{x}\n", .{state});
                    state = @select(u24, state != all_zero, all_zero, right);
                } else {
                    // std.debug.print("---R--{x}\n", .{state});
                    for (0..input_len) |ci| {
                        state[std.simd.firstIndexOfValue(start, state[ci]).?] = state[ci];
                    }
                    state = @select(u24, state == start, start, all_zero);

                    // std.debug.print("---R--{x}\n", .{state});
                    // std.debug.print("---RRRR--{x}\n", .{right});
                    state = @select(u24, state == all_zero, all_zero, right);
                    // std.debug.print("---R--{x}\n", .{state});
                }
            }
            var check_finished = state;
            check_finished &= last_byte;
            const z = check_finished == z_vec;
            check_finished = @select(u24, z, all_zero, check_finished);

            if (@reduce(.And, check_finished == all_zero)) {
                break;
            }

            // std.debug.print("ffs{b}\n", .{state});
            // std.debug.print("fff{b}\n", .{check_finished});
            // check_finished |= first_byte;
            // std.debug.print("fff{b}\n", .{check_finished});
            // check_finished ^= ~z_vec;
            // // check_finished = ~check_finished;
            // std.debug.print("fff{b}\n", .{check_finished});
            //
            // if (@reduce(.And, (check_finished) == all_zero)) {
            //     break;
            // }
        }
        step += 1;
        std.debug.print("{}    {}\n", .{ state, step });
        std.mem.sortUnstable();

        // std.simd

        // var abz: u24 = 0;
        // const a: u8 = 'A';
        // const b: u8 = 'B';
        // const z: u8 = '1';
        // std.debug.print("a:{b}\n", .{a});
        // std.debug.print("b:{b}\n", .{b});
        // std.debug.print("c:{b}\n", .{z});
        // std.debug.print("{b}\n", .{abz});
        // abz |= a;
        // abz <<= 7;
        // //
        // std.debug.print("{b:0<24}\n", .{abz});
        // abz |= b;
        // abz <<= 7;
        // //
        // std.debug.print("{b}\n", .{abz});
        // abz |= z;
        // std.debug.print("{b}\n", .{abz});
        //
        // abz ^= z;
        // std.debug.print("abz xor z: {b}", .{abz});
    }
}
