const std = @import("std");
const input = @embedFile("input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    // defer _ = gpa.deinit();

    var in_line_it = std.mem.tokenize(u8, input, "\n");

    //get tower lines
    var line_number: usize = 0;
    _ = line_number;

    var towers = std.ArrayList(std.ArrayList(u8)).init(alloc);
    defer alloc.free(towers);

    //while tower block is not digested
    while (true) {
        var line = in_line_it.next().?;
        if (line[1] == '1') {
            break;
        }

        var i: usize = 1; //first letter of first tower is at position1 in line
        var tower_rows = std.ArrayList(u8).init(alloc);
        while (i < line.len) : (i += 4) { //four chars between towers
            try tower_rows.append(line[i]);
        }
        try towers.append(tower_rows);
        tower_rows.clearRetainingCapacity();
    }

    std.debug.print("{any}", .{towers.items});
}
