const std = @import("std");
const input = @embedFile("input.txt");
const tokenize = std.mem.tokenize;

const races = 4;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    _ = alloc;

    var it = tokenize(u8, input, "\n");

    var times_it = tokenize(u8, it.next().?, " ");
    //discard Time: at beginning of line
    _ = times_it.next();

    var distance_it = tokenize(u8, it.next().?, " ");
    //discard Distance1: at beginning of line
    _ = distance_it.next();

    var current_records: [4][2]usize = .{.{@as(usize, 0)} ** 2} ** 4;

    var i: usize = 0;
    while (times_it.next()) |t| : (i += 1) {
        const d = distance_it.next().?;
        current_records[i] = @Vector(2, usize){ try std.fmt.parseInt(usize, t, 10), try std.fmt.parseInt(usize, d, 10) };
    }

    // std.debug.print("current_records: {any}\n", .{current_records});

    var part1_result: usize = 1;
    for (current_records) |game| {
        var ways_to_beat_record: usize = 0;
        for (0..game[0]) |speed| {
            const distance = (game[0] - speed) * speed;
            if (distance > game[1]) {
                ways_to_beat_record += 1;
                // std.debug.print("time: {} time_button: {} distance: {}\n", .{ game[0], speed, distance });
            }
        }
        part1_result *= ways_to_beat_record;
    }
    std.debug.print("part1_result: {}\n", .{part1_result});

    var new_time_str: [64]u8 = .{@as(u8, 0)} ** 64;
    var new_time_strs = try std.fmt.bufPrint(&new_time_str, "{}{}{}{}", .{ current_records[0][0], current_records[1][0], current_records[2][0], current_records[3][0] });
    std.debug.print("new_time: {s}\n", .{new_time_str});

    var new_dist_str: [64]u8 = .{@as(u8, 0)} ** 64;
    var new_dist_strs = try std.fmt.bufPrint(&new_dist_str, "{}{}{}{}", .{ current_records[0][1], current_records[1][1], current_records[2][1], current_records[3][1] });
    std.debug.print("new_dist: {s}\n", .{new_dist_str});

    std.debug.print("time.len: {}\n ", .{&new_time_str.len});

    const new_time = try std.fmt.parseInt(usize, new_time_strs, 10);
    const new_dist = try std.fmt.parseInt(usize, new_dist_strs, 10);

    var part2_result: usize = 0;
    for (0..new_time) |speed| {
        if ((new_time - speed) * speed > new_dist) part2_result += 1;
    }
    std.debug.print("part2: {}\n", .{part2_result});
}
