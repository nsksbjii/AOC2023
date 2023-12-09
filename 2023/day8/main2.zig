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
        var start_2 = std.ArrayList([]const u8).init(alloc);
        defer start_2.deinit();

        var it = std.mem.tokenize(u8, input, "\n=(), ");
        const lrpattern = it.next().?;
        while (it.next()) |tok| {
            const k = tok;
            const a = [2][]const u8{ it.next().?, it.next().? };
            try productions.put(k, a);
            if (k[2] == 'A') try start_2.append(tok);
        }

        {
            var step: usize = 0;
            while (true) : (step += 1) {
                // std.debug.print("{s} -->", .{start});
                const p = @mod(step, lrpattern.len);
                for (start_2.items) |*s| {
                    const production = productions.get(s.*).?;
                    s.* = if (lrpattern[p] == 'L') production[0] else production[1];
                }
                // std.debug.print("{s}  {s} {}\n", .{ start, lrpattern[p .. p + 1], p });
                for (start_2.items) |s| {
                    if (!(s[2] == 'Z')) break;
                } else {
                    break;
                }
                std.debug.print("start_2 {s} step: {}\n", .{ start_2.items, step });
            }
            step += 1;

            std.debug.print("steps: {}\n", .{step});
        }
    }
}
