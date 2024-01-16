//start of packet 4 distinct chars
//find offset to first packet
const std = @import("std");
const input = @embedFile("input.txt");
// const input = "mjqjpqmgbljsphdztnvjfqwrcgsmlb";
pub fn main() !void {
    {
        var offset: usize = 0;
        while (offset < input.len - 4) : (offset += 1) {
            inner: for (offset..offset + 4) |i| {
                for (i + 1..offset + 4) |j| {
                    if (input[i] == input[j]) {
                        break :inner;
                    }
                }
            } else {
                offset += 4;
                break;
            }
        }

        std.debug.print("offset: {}\n", .{offset});
    }
    {
        var offset: usize = 0;
        while (offset < input.len - 14) : (offset += 1) {
            inner: for (offset..offset + 14) |i| {
                for (i + 1..offset + 14) |j| {
                    if (input[i] == input[j]) {
                        break :inner;
                    }
                }
            } else {
                offset += 14;
                break;
            }
        }

        std.debug.print("offset: {}\n", .{offset});
    }
}
