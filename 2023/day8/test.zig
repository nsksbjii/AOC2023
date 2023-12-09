const std = @import("std");
const input = @embedFile("input.txt");
// const input = @embedFile("input_small_2.txt");
// const input_len = 8;
const input_len = 757;

pub fn main() !void {
    std.debug.print("{}", .{std.simd.suggestVectorSize(u24).?});
    const a = "AAA";
    std.debug.print("{any}", .{std.mem.asBytes(a.*)});
}
