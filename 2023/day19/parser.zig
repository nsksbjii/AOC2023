const std = @import("std");
const tokenize = std.mem.tokenize;
const indexOf = std.mem.indexOf;
const indexOfAny = std.mem.indexOfAny;
const parseInt = std.fmt.parseInt;
// const Order = std.math.Order;
const WF = @import("workflow.zig");
const P = @import("part.zig");
const Workflow = WF.Workflow;
const Rule = WF.Rule;
const Part = P.Part;

//  px{a<2006:qkq,m>2090:A,rfg}
pub fn parseWorkflow(in: []const u8) !Workflow {
    var it = tokenize(u8, in, "{},");
    const name = it.next().?;
    var rules: [4]?Rule = .{null} ** 4;
    var i: usize = 0;
    while (it.next()) |tok| : (i += 1) {
        const comparator_index = indexOfAny(u8, tok, "<>");
        if (comparator_index) |idx| {
            const symbol: u8 = tok[idx - 1];
            const condition: u8 = tok[idx];
            const colon_idx = indexOf(u8, tok, ":").?;
            const value = try parseInt(usize, tok[idx + 1 .. colon_idx], 10);
            const ret = tok[colon_idx + 1 ..];

            rules[i] = Rule{ .symbol = symbol, .condition = condition, .value = value, .ret_val = ret };
        } else {
            rules[i] = Rule{ .ret_val = tok };
        }
    }
    return Workflow{ .name = name, .rules = rules };
}

//{x=787,m=2655,a=1222,s=2876}
pub fn parsePart(in: []const u8) !Part {
    var it = tokenize(u8, in, "{},xmas=");
    return Part{
        .x = try parseInt(usize, it.next().?, 10),
        .m = try parseInt(usize, it.next().?, 10),
        .a = try parseInt(usize, it.next().?, 10),
        .s = try parseInt(usize, it.next().?, 10),
    };
}
