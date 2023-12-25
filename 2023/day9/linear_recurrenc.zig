const std = @import("std");
const input = @embedFile("input_small.txt");

pub fn main() !void {
    var it = std.mem.tokenize(u8, input, "\n");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var sequences = std.ArrayList(std.ArrayList(i32)).init(alloc);
    defer {
        for (sequences.items) |value| {
            value.deinit();
        }
        sequences.deinit();
    }

    while (it.next()) |line| {
        var sequnece = std.ArrayList(i32).init(alloc);

        var seq = std.mem.tokenize(u8, line, " ");
        while (seq.next()) |s| {
            try sequnece.append(try std.fmt.parseInt(i32, s, 10));
        }
        try sequences.append(sequnece);
    }

    for (sequences.items, 0..) |sequnece, si| {
        _ = si;
        //ccheck if po;ynomial roots are dustince
        var distinct = for (0..sequnece.items.len - 2) |i| {
            if (sequnece.items[i] == sequnece.items[i + 1]) {
                break false;
            }
        } else blk: {
            break :blk true;
        };

        std.debug.print("{any}  {}\n", .{ sequnece.items, distinct });
    }

    //Find cahracteristicc polinomial of root
    //
    // sequence roots are distinct
    //
    // x(t) = c(1)difference(1,t)+...+ c(n)difference(n,t)
    //
    // convert to homogenous form with no constant term
    // (y(t) - y*) = Sum(1..n)|i|(a(i)x(t-i)) - y*
    //
    // -> (y(t) - y*) = x(t)
    // x(t) = Sum(1..n)|i| a(i)y(t-i)
    //
    // find characteristec polinomial
    // la,bda(n) = Sum(2..n)|i|a(i)*lamda(n-1)jjhhjjj:e in
    //
    for (sequences.items, 0..) |sequnece, si| {
        _ = si;
        var x = try alloc.create([sequnece.items.len]i32);
        defer alloc.free(x);
        var c = try alloc.create(@Vector(sequnece.items.len, i32));
        defer alloc.free(c);
        var l = try alloc.create(@Vector(sequnece.items.len, i32));
        defer alloc.free(l);

        for (sequnece, 0..) |current, t| {
            x[t] = current;
            for (sequnece, 0..) |inner, ti| {
                _ = inner;
                c[ti] = (t - ti) / x[t]; //TODO
            }
        }

        const next = blk: {
            var sum: usize = 0;
            for (sequnece, 0..) |_, idx| {
                sum += c[idx] * (sequnece.items.len - idx); //TODO
            }
            break :blk sum;
        };

        std.debug.print("P:{}\n", .{next});
        // x(t) = c(1)difference(1,t)+...+ c(n)difference(n,t) /c
        // 0 = c[1..]lamdas[t][1..].
        // x / c = l
        //  c  = l/x

    }
}
