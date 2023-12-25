const std = @import("std");
const input = @embedFile("input.txt");
const tokenize = std.mem.tokenize;
const Arr = std.ArrayList;

fn hash(in: []const u8) usize {
    var ret: usize = 0;
    for (in) |c| {
        ret += c;
        ret *= 17;
        ret = @mod(ret, 256);
    }
    // std.debug.print("{s} -> {}\n", .{ in, ret });
    return ret;
}

const Box = struct {
    Id: usize,
    lenses: Arr(Lens),

    pub fn init(id: usize, alloc: std.mem.Allocator) Box {
        return Box{ .Id = id, .lenses = Arr(Lens).init(alloc) };
    }
    pub fn deinit(self: *Box) void {
        self.lenses.deinit();
    }

    pub fn focus_power(self: *Box) usize {
        var total: usize = 0;
        for (self.lenses.items, 1..) |value, i| {
            const current = (self.Id + 1) * i * (value.focal_len - '0'); //focal_len is ascii so has to be converted to int
            total += current;
        }
        return total;
    }

    // adds lens if lens with same label not in lenses
    // replaces lens if lens in lenses
    //returns true if replaced false if appended or error if append fails
    pub fn add_replace_lens(self: *Box, lens: Lens) !bool {
        for (self.lenses.items) |*l| {
            if (std.mem.eql(u8, l.label, lens.label)) {
                l.*.focal_len = lens.focal_len;
                return true;
            }
        } else {
            try self.lenses.append(lens);
            return false;
        }

        unreachable;
    }

    //returns Lens if removed or null if lens !exists
    pub fn remove_lens(self: *Box, lens: Lens) ?Lens {
        for (self.lenses.items, 0..) |l, i| {
            if (std.mem.eql(u8, l.label, lens.label)) {
                const removed = self.lenses.orderedRemove(i);
                return removed;
            }
        }
        return null;
    }
};

const Lens = struct {
    focal_len: u8 = undefined,
    label: []const u8,
};

const Instruction = struct {
    label: []const u8,
    operation: u8,
    focal_len: u8,

    pub fn init(instruction_str: []const u8) !Instruction {
        const op_idx = std.mem.indexOfAny(u8, instruction_str, "=-");
        if (op_idx) |i| {
            const label = instruction_str[0..i];
            const operation = instruction_str[i];
            const focal_len = if (operation == '=') instruction_str[i + 1] else undefined;
            return Instruction{ .label = label, .operation = operation, .focal_len = focal_len };
        } else {
            return error.InvalidInput;
        }
    }
    pub fn execute(self: *Instruction, boxes: *Arr(Box)) !void {
        const box_nr = hash(self.label);
        switch (self.operation) {
            '=' => {
                const ret = try boxes.items[box_nr].add_replace_lens(Lens{ .label = self.label, .focal_len = self.focal_len });
                if (ret) {
                    std.debug.print("replaced lens: {s} {c} in box {}\n", .{ self.label, self.focal_len, box_nr });
                } else {
                    std.debug.print("added lens: {s} {c} to box {}\n", .{ self.label, self.focal_len, box_nr });
                }
            },
            '-' => {
                const ret = boxes.items[box_nr].remove_lens(Lens{ .label = self.label });
                if (ret) |r| {
                    std.debug.print("removed lens: {s} {c} from box {}\n", .{ r.label, r.focal_len, box_nr });
                }
            },
            else => {
                unreachable;
            },
        }
    }
};
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    //initialize boxes
    var boxes = Arr(Box).init(alloc);
    defer {
        for (boxes.items) |*i| {
            i.deinit();
        }
        boxes.deinit();
    }
    for (0..256) |i| {
        try boxes.append(Box.init(i, alloc));
    }

    var total: usize = 0;
    var it = tokenize(u8, input, ",\n");
    while (it.next()) |tok| {
        total += hash(tok);
        var instr = try Instruction.init(tok);
        try instr.execute(&boxes);
    }
    std.debug.print("Part 1: {}\n", .{total});

    var part2: usize = 0;
    for (boxes.items) |*b| {
        part2 += b.focus_power();
    }
    std.debug.print("Part 2: {}\n", .{part2});
}
