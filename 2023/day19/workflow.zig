const std = @import("std");
// const Order = std.math.Orde;
const P = @import("part.zig");
const Part = P.Part;

pub const Rule = struct {
    symbol: u8 = 0,
    condition: u8 = undefined,
    value: usize = 0,
    ret_val: []const u8,

    pub fn match(self: *const Rule, v: u8, val: usize) ?[]const u8 {
        if (self.symbol == 0) return self.ret_val;
        if (v != self.symbol) {
            std.debug.print("v: {c} self.symbol: {c}\n", .{ v, self.symbol });
            unreachable;
        }
        switch (self.condition) {
            '<' => {
                if (val < self.value) return self.ret_val;
            },

            '>' => {
                if (val > self.value) return self.ret_val;
            },
            else => {
                std.debug.print("invalid symbol!!  {c}\n", .{self.symbol});
                unreachable;
            },
        }
        return null;
    }
};
const partIdSymbolMap: [4]u8 = .{ 'x', 'm', 'a', 's' };

pub const Workflow = struct {
    name: []const u8,
    rules: [4]?Rule = .{null} ** 4,

    pub fn process(self: *Workflow, part: Part) []const u8 {
        for (self.rules) |rr| {
            if (rr) |r| {
                switch (r.symbol) {
                    0 => {
                        return r.ret_val;
                    },
                    'x' => {
                        const maybe_match = r.match('x', part.x);
                        if (maybe_match) |m| return m;
                    },
                    'm' => {
                        const maybe_match = r.match('m', part.m);
                        if (maybe_match) |m| return m;
                    },
                    'a' => {
                        const maybe_match = r.match('a', part.a);
                        if (maybe_match) |m| return m;
                    },
                    's' => {
                        const maybe_match = r.match('s', part.s);
                        if (maybe_match) |m| return m;
                    },
                    else => {
                        unreachable;
                    },
                }
            }
        }
        unreachable;
    }
};
