const std = @import("std");
const input = @embedFile("input.txt");
const ArrI32 = std.ArrayList(i32);
const Seq = std.ArrayList(ArrI32);
const ArrayList = std.ArrayList;

fn printSequence(seq: Seq) void {
    for (seq.items) |i| {
        std.debug.print("{any}\n", .{i.items});
    }
    std.debug.print("\n\n\n", .{});
}

fn fillSequence(seq: Seq) void {
    var depth = seq.items.len - 2; //-1 bc 0 index +(-1) bc last item is all 0

    //fill first and  last 0 in bottom subseq
    seq.items[depth].items[seq.items[depth].items.len - 1] = seq.items[depth].items[1];
    seq.items[depth].items[0] = seq.items[depth].items[1];
    while (depth > 0) {
        defer depth -= 1;

        var current: *ArrI32 = &seq.items[depth];
        var up: *ArrI32 = &seq.items[depth - 1];

        // const clidx = current.items.len - 1;
        const clast: i32 = current.getLast();
        const cfirst = current.items[0];

        const ulidx = up.items.len - 1;
        var ulast: *i32 = &up.items[ulidx]; // placeholder 0 at end
        var ufirst: *i32 = &up.items[0]; // placeholder 0 at beginning
        const uprev_last: *i32 = &up.items[ulidx - 1]; // last actual entry
        const uprev_first: *i32 = &up.items[1]; // first actual entry
        ulast.* = uprev_last.* + clast;
        ufirst.* = uprev_first.* - cfirst;
    }
}

fn sumExtrapolated(seqs: ArrayList(Seq)) struct { i32, i32 } {
    var sum_back: i32 = 0;
    var sum_front: i32 = 0;
    for (seqs.items) |seq| {
        sum_back += seq.items[0].getLast();
        sum_front += seq.items[0].items[0];
    }

    return .{ sum_front, sum_back };
}

pub fn main() !void {
    var it = std.mem.tokenize(u8, input, "\n");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    var sequneces = ArrayList(Seq).init(alloc);
    defer {
        for (sequneces.items) |seq| {
            for (seq.items) |i| {
                i.deinit();
            }
            seq.deinit();
        }
        sequneces.deinit();
    }

    while (it.next()) |tok| {
        var subtok = std.mem.tokenize(u8, tok, " ");

        var sequnece = Seq.init(alloc);
        var s = ArrI32.init(alloc);
        while (subtok.next()) |t| {
            try s.append(try std.fmt.parseInt(i32, t, 10));
        }
        // append placeholders to sequence to extrapolate forward and backward
        try s.append(@as(i32, 0));
        try s.insert(0, @as(i32, 0));
        try sequnece.append(s);

        //create new sequneces that contain the difference form one item to the next
        inner: while (true) {
            //create new sequence with len(prev_seq)-1 containing the difference between otems in the precious sequneces
            var new = ArrI32.init(alloc);
            const seq_size = sequnece.items.len;
            var prev: *ArrI32 = &sequnece.items[seq_size - 1];

            for (1..prev.items.len - 2) |i| {
                const diff: i32 = prev.items[i + 1] - prev.items[i];
                try new.append(diff);
            }
            //append plazeholders at beginning and end
            try new.append(@as(i32, 0)); // plazeholder to extrapolate backwards
            try new.insert(0, @as(i32, 0));

            try sequnece.append(new);

            //if new is all zero break
            for (new.items) |i| {
                if (i != 0) break;
            } else {
                break :inner;
            }
        }
        // printSequence(sequnece);
        fillSequence(sequnece);
        printSequence(sequnece);

        //append to current sequnece to sequneces
        try sequneces.append(sequnece);
    }
    std.debug.print("SUM: {any}\n", .{sumExtrapolated(sequneces)});
}
