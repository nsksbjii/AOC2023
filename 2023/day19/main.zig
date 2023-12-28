const std = @import("std");
const tokenize = std.mem.tokenize;
const split = std.mem.split;
const Order = std.math.Order;

const input = @embedFile("input.txt");

const WF = @import("workflow.zig");
const P = @import("part.zig");
const parser = @import("parser.zig");
const Workflow = WF.Workflow;
const Part = P.Part;
const PartArr = std.ArrayList(Part);
const WorkflowHMap = std.StringArrayHashMap(Workflow);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const galloc = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(galloc);
    defer arena.deinit();
    const alloc = arena.allocator();

    var Workflows = WorkflowHMap.init(alloc);
    var Parts = PartArr.init(alloc);

    var it = split(u8, input, "\n\n");
    var workflow_strs = tokenize(u8, it.next().?, "\n");
    var part_strs = tokenize(u8, it.next().?, "\n");

    while (workflow_strs.next()) |tok| {
        const wf = try parser.parseWorkflow(tok);
        // std.debug.print("{s}  ", .{tok});
        try Workflows.put(wf.name, wf);

        // std.debug.print("{s} {any}\n", .{ wf.name, wf.rules });
    }
    try Workflows.put("A", Workflow{ .name = "A" });
    try Workflows.put("R", Workflow{ .name = "R" });
    while (part_strs.next()) |tok| {
        // std.debug.print("{s}  ", .{tok});
        const part = try parser.parsePart(tok);
        try Parts.append(part);
        // std.debug.print("{}\n", .{part});
    }

    for (Parts.items) |part| {
        var current_workflow = Workflows.get("in").?;
        std.debug.print("Part: {any}\n", .{part});
        while (current_workflow.name[0] != 'R' and current_workflow.name[0] != 'A') {
            const next_wf_name = current_workflow.process(part);
            // std.debug.print("current: {s} next: {s}\n", .{ current_workflow.name, next_wf_name });
            // std.debug.print(" current_workflow.name: {s}\n", .{current_workflow.name});
            current_workflow = Workflows.get(next_wf_name).?;

            // std.debug.print("---current: {s} next: {s}\n", .{ current_workflow.name, next_wf_name });
        }
        if (current_workflow.name[0] == 'A') {
            std.debug.print("{} Accepted\n", .{part});
        } else if (current_workflow.name[0] == 'R') {
            std.debug.print("{} Rejcected\n", .{part});
        } else {
            unreachable;
        }
    }

    var range = Ranges{
        .x = .{ 1, 4000 },
        .m = .{ 1, 4000 },
        .a = .{ 1, 4000 },
        .s = .{ 1, 4000 },
    };
    const accepted_combinations = get_accepted_ranges(&Workflows, range, "in");
    std.debug.print("accepted_combinations: {}\n", .{accepted_combinations});
}

const Ranges = struct {
    x: struct { usize, usize },
    m: struct { usize, usize },
    a: struct { usize, usize },
    s: struct { usize, usize },

    pub fn product(self: *const Ranges) usize {
        return ((self.x[1] - self.x[0] + 1) * (self.m[1] - self.m[0] + 1) * (self.a[1] - self.a[0] + 1) * (self.s[1] - self.s[0] + 1));
    }
};
fn get_accepted_ranges(wfs: *WorkflowHMap, prev_ranges: Ranges, current_wf_name: []const u8) usize {
    if (current_wf_name[0] == 'R') return 0;
    if (current_wf_name[0] == 'A') {
        std.debug.print("Accepted_range: {}\n", .{prev_ranges});
        return prev_ranges.product();
    }
    var ranges = prev_ranges;

    const current_wf = wfs.get(current_wf_name).?;
    var total: usize = 0;
    for (current_wf.rules) |r| {
        if (r) |rule| {
            switch (rule.symbol) {
                'x' => {
                    var current_range = ranges.x;
                    var rule_true_for_range = if (rule.condition == '<') .{ current_range[0], rule.value - 1 } else .{ rule.value + 1, current_range[1] };
                    var rule_false_for_range = if (rule.condition == '<') .{ rule.value, current_range[1] } else .{ current_range[0], rule.value };
                    if (rule_true_for_range[0] <= rule_true_for_range[1]) {
                        ranges.x = rule_true_for_range;
                        total += get_accepted_ranges(wfs, ranges, rule.ret_val);
                    }
                    if (rule_false_for_range[0] <= rule_false_for_range[1]) {
                        ranges.x = rule_false_for_range;
                    } else {
                        // break;
                    }
                },
                'm' => {
                    var current_range = ranges.m;
                    var rule_true_for_range = if (rule.condition == '<') .{ current_range[0], rule.value - 1 } else .{ rule.value + 1, current_range[1] };
                    var rule_false_for_range = if (rule.condition == '<') .{ rule.value, current_range[1] } else .{ current_range[0], rule.value };
                    if (rule_true_for_range[0] <= rule_true_for_range[1]) {
                        ranges.m = rule_true_for_range;
                        total += get_accepted_ranges(wfs, ranges, rule.ret_val);
                    }
                    if (rule_false_for_range[0] <= rule_false_for_range[1]) {
                        ranges.m = rule_false_for_range;
                    } else {
                        // break;
                    }
                },
                'a' => {
                    var current_range = ranges.a;
                    var rule_true_for_range = if (rule.condition == '<') .{ current_range[0], rule.value - 1 } else .{ rule.value + 1, current_range[1] };
                    var rule_false_for_range = if (rule.condition == '<') .{ rule.value, current_range[1] } else .{ current_range[0], rule.value };
                    if (rule_true_for_range[0] <= rule_true_for_range[1]) {
                        ranges.a = rule_true_for_range;
                        total += get_accepted_ranges(wfs, ranges, rule.ret_val);
                    }
                    if (rule_false_for_range[0] <= rule_false_for_range[1]) {
                        ranges.a = rule_false_for_range;
                    } else {
                        // break;
                    }
                },
                's' => {
                    var current_range = ranges.s;
                    var rule_true_for_range = if (rule.condition == '<') .{ current_range[0], rule.value - 1 } else .{ rule.value + 1, current_range[1] };
                    var rule_false_for_range = if (rule.condition == '<') .{ rule.value, current_range[1] } else .{ current_range[0], rule.value };
                    if (rule_true_for_range[0] <= rule_true_for_range[1]) {
                        ranges.s = rule_true_for_range;
                        total += get_accepted_ranges(wfs, ranges, rule.ret_val);
                    }
                    if (rule_false_for_range[0] <= rule_false_for_range[1]) {
                        ranges.s = rule_false_for_range;
                    } else {
                        // break;
                    }
                },
                0 => {
                    total += get_accepted_ranges(wfs, ranges, rule.ret_val);
                },
                else => {
                    unreachable;
                },
            }
        }
    }
    return total;
}
