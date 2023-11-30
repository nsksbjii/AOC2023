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
        const new_addr = buf.addOne() catch |err| return err;
        @memcpy(new_addr[0..line.len], line);
        new_addr[line.len] = 0;
        lines_read += 1;
        read_buf = .{0} ** 128;
    }
    return lines_read;
}

fn snafu_to_dec(input: [128]u8) !i64 {
    //find length of input
    var length: usize = 0;
    for (input, 0..) |val, i| {
        if (val == 0) {
            length = i;
        }
    }
    length -= 1;

    var sum: i64 = 0;
    var exponent: i64 = 0;
    while (length >= 0) : (length -= 1) {
        const multiplyer: i64 = std.math.pow(i64, 5, exponent);
        switch (input[length]) {
            48...53 => { //corresponds to '0'..'5'
                sum += (input[length] - 48) * multiplyer;
            },
            '=' => {
                sum -= multiplyer * 2;
            },
            '-' => {
                sum -= multiplyer;
            },
            else => {
                return error.InvalidCharacter;
            },
        }
        exponent += 1;

        if (length == 0) {
            break;
        }
    }

    return sum;
}

fn dec_to_snafu(dec: i64, str_buf: *std.ArrayList(u8)) !usize {
    var total = dec;
    var remainder: i64 = undefined;
    var nrwritten: usize = 0;
    while (total > 0) {
        remainder = @mod(total, 5);
        total = @divFloor(total, 5);
        switch (remainder) {
            0 => {
                try str_buf.append('0');
            },

            1 => {
                try str_buf.append('1');
            },

            2 => {
                try str_buf.append('2');
            },
            4 => {
                try str_buf.append('-');
                total += 1;
            },

            3 => {
                try str_buf.append('=');
                total += 1;
            },

            else => {
                return error.WTF;
            },
        }

        nrwritten += 1;
    }

    // //reverse str_buf for correct epresentation
    var idx = str_buf.items.len - 1;
    const len = str_buf.items.len - 1;
    while (idx >= (len / 2) + 1) : (idx -= 1) {
        const temp = str_buf.items[idx];
        str_buf.items[idx] = str_buf.items[len - idx];
        str_buf.items[len - idx] = temp;
    }

    return nrwritten;
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
    _ = nr_lines;

    var sum: i64 = 0;
    for (input.items) |current| {
        const testvar: i64 = snafu_to_dec(current) catch |err| return err;
        sum += testvar;
    }

    print("sum in dec: {}\n", .{sum});

    //create new strbuffer for snuf notation
    var snufalloc = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(snufalloc.deinit() == .ok);
    const out_allocatou = snufalloc.allocator();
    var snuf_buf = std.ArrayList(u8).init(out_allocatou);
    defer snuf_buf.deinit();

    const snuf_len = try dec_to_snafu(sum, &snuf_buf);
    _ = snuf_len;

    print("snafu: {s}\n", .{snuf_buf.items});
}
