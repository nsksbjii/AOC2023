const std = @import("std");
const input = @embedFile("input.txt");
// const input = "1abc2\npqr3stu8vwx\na1b2c3d4e5f\ntreb7uchet";
// const input = "two1nine\neightwothree\nabcone2threexyz\nxtwone3four\n4nineeightseven2\nzoneight234\n7pqrstsixteen";
//
pub fn main() !void {

    // var lines = std.mem.tokenize(u8, input, "\n");
    const part1_solution = part1();
    std.debug.print("Result part 1: {}\n", .{part1_solution});

    const part2_solution = part2();
    std.debug.print("REsult part2: {}\n", .{part2_solution});
}
fn part1() usize {
    var lines = std.mem.tokenize(u8, input, "\n");

    var sum: usize = 0;
    while (lines.next()) |line| {
        var first: u8 = 0xff;
        var last: u8 = 0xff;

        for (line) |byte| {
            switch (byte) {
                '0'...'9' => {
                    if (first == 0xff) {
                        first = byte;
                    } else {
                        last = byte;
                    }
                },
                else => {
                    continue;
                },
            }
        }

        var num_int: usize = undefined;
        if (last != 0xff) {
            // _ = std.fmt.bufPrint(&num, "{}{}", .{ first, last }) catch |err| std.debug.print("bufPrint: {} \n", .{err});
            // num_int = (std.fmt.parseInt(usize, "{}", .{first}, 10) catch 0) * 10 + (std.fmt.parseInt(usize, &last, 10) catch 0);
            num_int = (first - '0') * 10 + (last - '0');
        } else {
            if (first == 0xff) continue;
            num_int = (first - '0') * 10 + (first - '0');
        }
        // const num_int: usize = std.fmt.parseInt(usize, &num, 10) catch 0;
        // std.debug.print("num_int: {}\n", .{num_int});
        sum += num_int;
    }

    return sum;
}
fn part2() usize {
    var lines = std.mem.tokenize(u8, input, "\n");

    var sum: usize = 0;
    var line_nr: usize = 0;
    while (lines.next()) |line| {
        line_nr += 1;
        var first: u8 = 0;
        var last: u8 = 0;

        var i: usize = 0;
        while (i < line.len) : (i += 1) {
            switch (line[i]) {
                '0'...'9' => {
                    if (first == 0) {
                        first = line[i];
                    } else last = line[i];
                },
                else => {
                    if (std.mem.eql(u8, if (line.len >= i + 3) line[i .. i + 3] else line[0..1], "one")) {
                        if (first == 0) {
                            first = '1';
                        } else last = '1';
                    } else if (std.mem.eql(u8, if (line.len >= i + 3) line[i .. i + 3] else line[0..1], "two")) {
                        if (first == 0) {
                            first = '2';
                        } else last = '2';
                    } else if (std.mem.eql(u8, if (line.len >= i + 5) line[i .. i + 5] else line[0..1], "three")) {
                        if (first == 0) {
                            first = '3';
                        } else last = '3';
                    } else if (std.mem.eql(u8, if (line.len >= i + 4) line[i .. i + 4] else line[0..1], "four")) {
                        if (first == 0) {
                            first = '4';
                        } else last = '4';
                    } else if (std.mem.eql(u8, if (line.len >= i + 4) line[i .. i + 4] else line[0..1], "five")) {
                        if (first == 0) {
                            first = '5';
                        } else last = '5';
                    } else if (std.mem.eql(u8, if (line.len >= i + 3) line[i .. i + 3] else line[0..1], "six")) {
                        if (first == 0) {
                            first = '6';
                        } else last = '6';
                    } else if (std.mem.eql(u8, if (line.len >= i + 5) line[i .. i + 5] else line[0..1], "seven")) {
                        if (first == 0) {
                            first = '7';
                        } else last = '7';
                    } else if (std.mem.eql(u8, if (line.len >= i + 5) line[i .. i + 5] else line[0..1], "eight")) {
                        if (first == 0) {
                            first = '8';
                        } else last = '8';
                    } else if (std.mem.eql(u8, if (line.len >= i + 4) line[i .. i + 4] else line[0..1], "nine")) {
                        if (first == 0) {
                            first = '9';
                        } else last = '9';
                    }
                },
            }
        }

        var num_int: usize = 0;

        if (first == 0) unreachable;
        if (last != 0) {
            // _ = std.fmt.bufPrint(&num, "{}{}", .{ first, last }) catch |err| std.debug.print("bufPrint: {} \n", .{err});
            // num_int = (std.fmt.parseInt(usize, "{}", .{first}, 10) catch 0) * 10 + (std.fmt.parseInt(usize, &last, 10) catch 0);
            num_int = ((first - '0') * 10) + (last - '0');
            // std.debug.print("line: {s}  first: {} last: {}", .{ line, first - '0', last - '0' });
        } else {
            // num_int = (std.fmt.parseInt(usize, &first, 10) catch 0) * 10 + (std.fmt.parseInt(usize, &first, 10) catch 0);
            num_int = ((first - '0') * 10) + (first - '0');
            // std.debug.print("line: {s}   first: {} last: {}", .{ line, first - '0', first - '0' });
        }

        // const num_int: usize = std.fmt.parseInt(usize, &num, 10) catch 0;
        // std.debug.print("num_int: {}\n", .{num_int});
        sum += num_int;

        // std.debug.print(" num_int: {} sum: {}\n", .{ num_int, sum });
    }
    // std.debug.print("lines read: {}", .{line_nr});

    return sum;
}
