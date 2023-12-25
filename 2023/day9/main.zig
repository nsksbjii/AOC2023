const std = @import("std");
const input = @embedFile("input_small.txt");

pub fn main() !void {
    var it = std.mem.tokenize(u8, input, "\n");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var sequneces = std.ArrayList(std.ArrayList(i32)).init(alloc);
    defer {
        for (sequneces.items) |value| {
            value.deinit();
        }
        sequneces.deinit();
    }

    while (it.next()) |line| {
        var sequnece = std.ArrayList(i32).init(alloc);

        var seq = std.mem.tokenize(u8, line, " ");
        while (seq.next()) |s| {
            try sequnece.append(try std.fmt.parseInt(i32, s, 10));
        }
        try sequnece.append(sequnece);
    }

    for (sequneces.items) |sequnece| {
        var subsets = std.ArrayList(std.ArrayList(i32)).init(alloc);
        defer {
            for (subsets.items) |i| {
                i.deinit();
            }
            subsets.deinit();
        }

        {
            var subset = std.ArrayList(i32).init(alloc);
            try subset.append(try sequnece.clone());
            var i: usize = 0;
            while (i < subset.items[i].items.len - 1) {
                var j: usize = 0;
                var subsubset = std.ArrayList(i32).init(alloc);
                while (j < subset.items[i].items[j].len - 1) {
                    try subsubset.append(subset.items[j] - subset.items[j + i]);
                }
                try subset.append(subsubset);
                var all_0 = true;
                for (subsubset.items) |s| {
                    if (s != 0) all_0 = false;
                }
                if (all_0) break;
            }
        }
        {
            var i = subsets.items.len - 1;
            while (i > 0) : (i -= 1) {
                const last = subsets.items[i].getLast();
                var prev_last = subsets.items[i - 1].getLast().ptr;
                prev_last.* += last;
            }
        }
    }
}
