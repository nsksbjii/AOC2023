const std = @import("std");
const tokenize = std.mem.tokenize;
const split = std.mem.split;
const indexOf = std.mem.indexOf;
const indexOfAny = std.mem.indexOfAny;
const eql = std.mem.eql;
const SHMap = std.StringArrayHashMap;
const PulseArr = std.ArrayList(Pulse);

const input = @embedFile("input_small.txt");
const MAX_INPUT_BUF_SIZE = 10;

//comm module------------------commodule
//
//pulse:
//   high
//   low
//
//Flip-Flop - % prefix (on, __OFF)  ->highPulse{};->lowPulse{self.flip()(0->1) high (1->0) low}
//Conhunction - & prefix (prev_pulses(h,L)) ->pulse->update_input_mem->if all high ->low else -> high
//broadcaster - []recivers -sensd in to all recivers
//
//button(start) -> send low to broadcaster
//
//pulses are processed in send order -> BFS

const Pulse = enum {
    LOW,
    HIGH,
};
const NeworkModuleTag = enum {
    Broadcaster,
    FlipFlop,
    Conjunction,
};
const NeworkModule = union(NeworkModuleTag) {
    Broadcaster,
    FlipFlop: bool,
    Conjunction: []Pulse,
    Aptly,
};
const CommModule = struct {
    //
    name: []const u8,
    modType: NeworkModule,
    inputBuf: PulseArr = undefined,
    outputs: [][]const u8,

    //handle pulsees in inputBuf
    pub fn handlePulse(self: *CommModule, nodes: *SHMap(CommModule)) void {
        _ = nodes;

        for (self.inputBuf.items) |pulse| {
            switch (self.modType) {
                .FlipFlop => {
                    if (pulse == .LOW) {
                        const prev = self.modType.Conjunction;
                        self.modType.Conjunction = !self.modType.Conjunction;
                        if (!prev and self.modType.Conjunction) { //0 -> 1

                            //TODO

                        }
                        if (prev and !self.modType.Conjunction) { //1 -> 0

                            //TODO
                        }
                    }
                },
                .Conjunction => {
                    //TODO
                },
                .Broadcaster => {
                    //TODO
                },
            }
        }
    }
};

fn sendPulse(nodes: *SHMap(CommModule), node: []const u8, signal: Pulse) void {
    const module = nodes.get(node).?;
    switch (module.modType) {
        .Broadcaster => {
            for (module.outputs) |output| {
                var temp = nodes.get(output).?;
                try temp.inputBuf.append(signal);
            }
        },
        .Conjunction => { //TODO
        },
        .FlipFlop => { //TODO
        },
        else => {
            unreachable;
        },
    }
}

pub fn main() !void {

    //allocator boilerplate
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const galloc = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(galloc);
    defer arena.deinit();
    const alloc = arena.allocator();

    //main data structure StringArrayHashMap w/ CommModule as value
    var commNodes = SHMap(CommModule).init(alloc);

    //line iterator
    var it = tokenize(u8, input, "\n");
    //go over every input line and parse modules and their out puts
    while (it.next()) |line| {
        std.debug.print("{s}\n", .{line});
        //split line into CommModule  and outputs
        var inout = split(u8, line, " -> ");
        var module_str = inout.next().?;
        var outputs_str = inout.next().?;
        var out_tok = tokenize(u8, outputs_str, " ,");
        var outputs: [][]const u8 = try alloc.alloc([]const u8, 1);
        var i: usize = 0;
        while (out_tok.next()) |out| : (i += 1) {
            outputs[i] = out;
            outputs = try alloc.realloc(outputs, outputs.len + 1);
        }

        //find Type of Module and its name from rhs of line
        var modType: NeworkModule = undefined;
        var name: []const u8 = undefined;
        switch (module_str[0]) {
            '%' => {
                modType = NeworkModule{ .FlipFlop = false };
                name = module_str[1..];
            },

            '&' => {
                modType = NeworkModule{ .Conjunction = undefined };
                name = module_str[1..];
            },
            'b' => {
                name = module_str;
                modType = .Broadcaster;
            },
            else => {
                unreachable;
            },
        }
        var node = CommModule{ .name = name, .outputs = outputs, .modType = modType, .inputBuf = try PulseArr.init(alloc) };

        std.debug.print("{s} {} {s}\n", .{ node.name, node.modType, node.outputs[0 .. node.outputs.len - 1] });
        try commNodes.put(node.name, node);
    }

    //for Conjunctions find all input nodes and initialize remembered value with with LOW
    for (commNodes.values()) |*n| {
        if (n.modType == .Conjunction) {
            var inputs: usize = 0;
            for (commNodes.values()) |nn| {
                for (nn.outputs) |out| {
                    if (eql(u8, n.name, out)) inputs += 1;
                }
            }

            var ins = try alloc.alloc(Pulse, inputs);
            n.modType = NeworkModule{ .Conjunction = ins };
            for (n.modType.Conjunction) |*ii| {
                ii.* = .LOW;
            }
        }
    }

    for (commNodes.values()) |node| {
        std.debug.print("{s} {} {s}\n", .{ node.name, node.modType, node.outputs[0 .. node.outputs.len - 1] });
    }
}

fn countPropagatedPulses(nodes: *SHMap(CommModule)) usize {
    //at start a single LOW pulse is sent to Broadcaster
    sendPulse(nodes, "broadcaster", .LOW);
    var sentPulse = true;
    while (sentPulse) {
        sentPulse = false;
        for (nodes.values()) |node| {
            if (node.inputBuf.items.len == 0) continue;
            //for exery pulse in inputBuf handle pulse-
            //

        }
    }
}
