const std = @import("std");

const stdin = std.io.getStdIn();
const stdout_file = std.io.getStdOut().writer();
const print = std.debug.print;
var stdin_buf = std.io.bufferedReader(stdin.reader());

// Reads stdin line by line until EOF
// lines are stored in buf
// returns nr. lines read or error
fn read_input(buf: *std.ArrayList([128]u8)) !usize {
    var lines_read: usize = 0;
    var read_buf: [128]u8 = .{0} ** 128;

    const in = stdin_buf.reader();

    while (try in.readUntilDelimiterOrEof(&read_buf, '\n')) |line| {
        if (line.len == 0) continue;
        if (std.mem.eql(u8, line, "EOF")) break;

        //std.debug.print("line: {s}\n", .{line});
        //
        const new_addr = buf.addOne() catch |err| return err;
        @memcpy(new_addr[0..line.len], line);

        new_addr[line.len] = 0;
        // buf.append(line[0..line.len]) catch |err| return err;
        lines_read += 1;
        read_buf = .{0} ** 128;
    }

    return lines_read;
}

fn snafu_to_dec(input: [128]u8) !i64 {
    //find length of input
    var length: usize = 0;
    for (input, 0..) |val, i| {
        //        std.debug.print("value: {}, index: {}\n", .{ val, i });
        if (val == 0) {
            length = i;
        }
    }
    length -= 1;

    var sum: i64 = 0;
    var exponent: i64 = 0;

    while (length >= 0) : (length -= 1) {
        print("len: {}\n", .{length});
        print("{}\n", .{input[length]});
        switch (input[length]) {
            '0'...'4' => { //corresponds to '0'..'5'
                //
                const multiplyer = std.math.pow(i64, 5, exponent);

                std.debug.print("multiplyer:{}, exponent:{}\n", .{ multiplyer, exponent });
                const parsed = try std.fmt.parseInt(u8, .{input[length]}, 10);
                sum += parsed * multiplyer;
            },
            '=' => {
                const multiplyer = std.math.pow(i64, 5, exponent);
                std.debug.print("multiplyer:{}, exponent:{}\n", .{ multiplyer, exponent });
                sum -= multiplyer * 2;
            },

            '-' => {
                const multiplyer = std.math.pow(i64, 5, exponent);
                std.debug.print("multiplyer:{}, exponent:{}\n", .{ multiplyer, exponent });
                sum -= multiplyer;
            },

            else => {
                return error.InvalidCharacter;
            },
        }
        exponent += 1;

        if (length == 0) break;
    }

    return sum;
}

pub fn main() !void {

    //initialize allocator to read input from stdin
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const input_allocator = gpa.allocator();

    //create onput array and read input line by line from stdin
    var input = std.ArrayList([128]u8).init(input_allocator);
    defer input.deinit();

    const nr_lines: usize = read_input(&input) catch |err| return err;

    var sum: i64 = 0;
    for (input.items) |current| {
        const testvar: i64 = snafu_to_dec(current) catch |err| return err;
        sum += testvar;
    }

    std.debug.print("lines read: {}\n", .{nr_lines});
    print("sum in dec: {}\n", .{sum});
}
