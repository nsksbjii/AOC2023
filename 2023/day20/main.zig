const std = @import("std");
const tokenize = std.mem.tokenize;
const split = std.mem.split;
const isEqual = std.mem.eql;

const input = @embedFile("input.txt");
const BUF_SIZE = 50;
const PART = 1; //part 2 is brueteforce attempt but problem is to hard to bruteforce need math

////Main DataStructs
const SigBuf = std.ArrayList(Signal);
const ModuleMap = std.StringArrayHashMap(CommModule);

////Signal
const Pulse = enum {
    LOW,
    HIGH,
};
const Signal = struct {
    from: []const u8 = undefined,
    to: []const u8 = undefined,
    signal: Pulse,
};

const SingalQueue = SigBuf;

fn sendSignals(from: []const u8, to: [][]const u8, nodes: *ModuleMap, pulse: Pulse, queue: *SingalQueue) !usize {
    var totalSent: usize = 0;

    for (to) |reciverName| {
        // if (isEqual(u8, reciverName, "rx")) std.debug.print("RX! {}\n", .{pulse});
        if (PART == 2 and isEqual(u8, reciverName, "rx") and pulse == .LOW) {
            return 1_000_000_000;
        }
        if (isEqual(u8, reciverName, "output") or isEqual(u8, reciverName, "rx")) {
            // std.debug.print("{s} --{}--> {s}\n", .{ from, pulse, reciverName });
            return 1;
        }

        const rec = nodes.getPtr(reciverName);
        if (rec) |reciver| {
            // std.debug.print("{s} --{}--> {s}\n", .{ from, pulse, reciver.name });
            const toSend = Signal{ .from = from, .to = reciver.name, .signal = pulse };
            // try reciver.*.inputBuf.append(toSend);
            try queue.append(toSend);
            totalSent += 1;
        } else {
            if (reciverName.len > 0) std.debug.print("ErrorDid not find:{s} \n", .{reciverName});
        }
    }
    return totalSent;
}

////CommuniacationModule
const ModuleType = enum {
    Broadcaster,
    FlipFlop,
    Conjunction,
};

const CommModule = struct {
    type: ModuleType,
    name: []const u8,
    inputBuf: SigBuf,
    outputs: [][]const u8,
    state: []Signal = undefined,
    pub fn handleSignalQ(self: *CommModule, nodes: *ModuleMap, queue: *SingalQueue, signal: Signal) !struct { Pulse, usize } {
        switch (self.type) {
            .FlipFlop => {
                if (signal.signal == .LOW) {
                    const prefState = self.state[0].signal;
                    self.state[0].signal = if (prefState == .LOW) .HIGH else .LOW; //flip on/off
                    if (prefState == .LOW) { //0->1 send HIGH

                        return .{ .HIGH, try sendSignals(self.name, self.outputs, nodes, .HIGH, queue) };
                    } else { // 1->0 send LOW
                        return .{ .LOW, try sendSignals(self.name, self.outputs, nodes, .LOW, queue) };
                    }
                }
                // HIGH Pulses are ignored by flipflop
            },
            .Broadcaster => {
                return .{ signal.signal, try sendSignals(self.name, self.outputs, nodes, signal.signal, queue) };
            },
            .Conjunction => {
                for (0..self.state.len - 1) |i| {
                    var state = self.state[i];
                    // std.debug.print("self.state.from = {s} signal.from = {s} for modue: {s} state index {}\n ", .{ state.from, signal.from, self.name, i });
                    if (isEqual(u8, state.from, signal.from)) {
                        // std.debug.print("{s}::::{s} {}  {}\n", .{ self.name, state.from, state.signal, i });
                        // std.debug.print("Conjunction state before: {}\n", .{self.state[i].signal});
                        self.state[i].signal = signal.signal;
                        // std.debug.print("Conjunction state after: {}\n", .{self.state[i].signal});
                    }
                }
                for (0..self.state.len - 1) |i| {
                    var s = self.state[i];
                    // std.debug.print("+++++{s}->{}\n ", .{ s.from, s.signal });
                    if (s.signal == .LOW) break;
                } else { //not all remembered signals are HIGH so send HIGH
                    // std.debug.print("--\n", .{});
                    return .{ .LOW, try sendSignals(self.name, self.outputs, nodes, .LOW, queue) };
                }
                // std.debug.print("\n", .{});
                return .{ .HIGH, try sendSignals(self.name, self.outputs, nodes, .HIGH, queue) };
                //all remembered input signals are HIGH so send Low
            },
        }
        return .{ .LOW, 0 };
    }
    //pops signal from SigBuf -> orderedRemove(index=0) since signals are appended to list
    //handle signal according to ModuleType Definition
    //returns number of signals sent
    pub fn handleSignal(self: *CommModule, nodes: *ModuleMap) !struct { Pulse, usize } {
        if (self.inputBuf.items.len <= 0) return .{ .LOW, 0 };
        const currentSignal = self.inputBuf.orderedRemove(0);
        switch (self.type) {
            .FlipFlop => {
                if (currentSignal.signal == .LOW) {
                    const prefState = self.state[0].signal;
                    self.state[0].signal = if (prefState == .LOW) .HIGH else .LOW; //flip on/off
                    if (prefState == .LOW) { //0->1 send HIGH

                        return .{ .HIGH, try sendSignals(self.name, self.outputs, nodes, .HIGH) };
                    } else { // 1->0 send LOW
                        return .{ .LOW, try sendSignals(self.name, self.outputs, nodes, .LOW) };
                    }
                }
                // HIGH Pulses are ignored by flipflop
            },
            .Broadcaster => {
                return .{ currentSignal.signal, try sendSignals(self.name, self.outputs, nodes, currentSignal.signal) };
            },
            .Conjunction => {
                // std.debug.print("######################\n", .{});
                for (0..self.state.len - 1) |i| {
                    var state = self.state[i];
                    // std.debug.print("self.state.from = {s} signal.from = {s} for modue: {s} state index {}\n ", .{ state.from, currentSignal.from, self.name, i });
                    if (isEqual(u8, state.from, currentSignal.from)) {
                        self.state[i].signal = currentSignal.signal;
                    }
                }
                for (self.state) |s| {
                    // std.debug.print("+++++{} ", .{s.signal});
                    if (s.signal != .LOW) break;
                } else { //not all remembered signals are HIGH so send HIGH
                    // std.debug.print("--\n", .{});
                    return .{ .HIGH, try sendSignals(self.name, self.outputs, nodes, .HIGH) };
                }
                // std.debug.print("\n", .{});
                //all remembered input signals are HIGH so send Low
                return .{ .LOW, try sendSignals(self.name, self.outputs, nodes, .LOW) };
            },
        }
        return .{ .LOW, 0 };
    }
};

pub fn main() !void {
    //allocator boilerplate
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const galloc = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(galloc);
    defer arena.deinit();
    const alloc = arena.allocator();

    //main data structure StringArrayHashMap w/ CommModule as value
    var commNodes = ModuleMap.init(alloc);
    var queue = SingalQueue.init(alloc);

    var it = tokenize(u8, input, "\n");
    while (it.next()) |line| {
        // std.debug.print("{s}\n", .{line});
        var nameOutputIt = split(u8, line, " -> ");
        const moduleStr = nameOutputIt.next().?;
        const outputStr = nameOutputIt.next().?;
        var out_tok = tokenize(u8, outputStr, " ,");
        var outputs: [][]const u8 = try alloc.alloc([]const u8, 1);
        var i: usize = 0;
        while (out_tok.next()) |out| : (i += 1) {
            outputs[i] = out;
            outputs = try alloc.realloc(outputs, outputs.len + 1);
        }
        // std.debug.print("outLEn: {}\n", .{outputs.len});
        outputs[outputs.len - 1] = "";
        // outputs = try alloc.realloc(outputs, outputs.len - 1);

        //find Type of Module and its name from rhs of line
        var modType: ModuleType = undefined;
        var name: []const u8 = undefined;
        switch (moduleStr[0]) {
            '%' => {
                modType = .FlipFlop;
                name = moduleStr[1..];
            },

            '&' => {
                modType = .Conjunction;
                name = moduleStr[1..];
            },
            'b' => {
                name = moduleStr;
                modType = .Broadcaster;
            },
            else => {
                unreachable;
            },
        }
        var node = CommModule{ .name = name, .outputs = outputs, .type = modType, .inputBuf = SigBuf.init(alloc) };
        // std.debug.print("{s} {} {s}\n", .{ node.name, node.type, node.outputs[0 .. node.outputs.len - 1] });
        try commNodes.put(node.name, node);
    }

    //for Conjunctions: for every ninput store sender and .Low in  signal arr
    //for flipflops create [1]Signal with Pulse.LOW
    for (commNodes.values()) |*n| {
        if (n.type == .Conjunction) {
            var prevSignals = try alloc.alloc(Signal, 1);
            for (commNodes.values()) |nn| {
                for (nn.outputs) |out| {
                    if (isEqual(u8, n.name, out)) {
                        prevSignals[prevSignals.len - 1].from = nn.name;
                        prevSignals[prevSignals.len - 1].to = n.name;
                        prevSignals[prevSignals.len - 1].signal = .LOW;
                        prevSignals = try alloc.realloc(prevSignals, prevSignals.len + 1);
                    }
                }
            }

            // std.debug.print("prevSignals: {any}\n", .{prevSignals[0 .. prevSignals.len - 1]});
            n.state = prevSignals;
            for (n.state) |*ii| {
                ii.*.signal = .LOW;
            }
        } else if (n.type == .FlipFlop) {
            n.state = try alloc.alloc(Signal, 1);
            n.state[0].signal = .LOW;
        }
    }

    if (PART == 1) {
        // for (commNodes.values()) |node|
        // std.debug.print("{s} {} {s} {}\n", .{ node.name, node.type, node.outputs[0 .. node.outputs.len - 1], if (node.type == .FlipFlop or node.type == .Conjunction) node.state[0].signal else Pulse.HIGH });
        // }
        //
        // std.debug.print("KEY/TOS:\n", .{});
        // for (commNodes.keys()) |value| {
        //     std.debug.print("{s}\n", .{value});
        // }

        //send LOW pulse to Broadcaster to start cascade
        //propagate signals until no more are sent
        //count and print total # sent

        var recipient0 = try alloc.alloc([]const u8, 1);
        recipient0[0] = "broadcaster";
        var totalLOW: usize = 0;
        var totalHIGH: usize = 0;
        for (0..1000) |_| {
            _ = try sendSignals("aptly", recipient0, &commNodes, .LOW, &queue);
            const result = try propagateQ(&commNodes, &queue);
            totalLOW += result[0] + 1; //+1 because initial signal fro mbutton is not included yet
            totalHIGH += result[1];
            // std.debug.print("\n\n", .{});
            // std.debug.print("LOW:{} HIGH: {}\n\n", .{ result[0], result[1] });
        }
        const totalSignalsSent = totalLOW * totalHIGH;
        std.debug.print("totalSent: {}\n", .{totalSignalsSent});
    }
    if (PART == 2) {
        var recipient0 = try alloc.alloc([]const u8, 1);
        recipient0[0] = "broadcaster";
        for (0..1_000_000) |i| {
            _ = try sendSignals("aptly", recipient0, &commNodes, .LOW, &queue);
            const result = try propagateQ(&commNodes, &queue);
            if (result[0] == 0 and result[1] == 0) {
                std.debug.print("Part2: {}\n", .{i});
                break;
            }
        }
    }
}
fn propagateQ(nodes: *ModuleMap, queue: *SingalQueue) !struct { usize, usize } {
    var totalSentLOW: usize = 0;
    var totalSentHIGH: usize = 0;
    while (queue.items.len > 0) {
        const signal = queue.orderedRemove(0);
        // std.debug.print("currentSignal {s}  --> {s}  {}\n", .{ signal.from, signal.to, signal.signal });
        const destNode = nodes.getPtr(signal.to).?;
        // std.debug.print("TO: {s}\n", .{signal.to});

        const sent = try destNode.handleSignalQ(nodes, queue, signal);
        // if (sent[1] > 100) std.debug.print("{}\n", .{sent[1]});
        if (PART == 2 and sent[0] == .LOW and sent[1] == 1_000_000_000) {
            return .{ 0, 0 };
        }
        if (sent[0] == .LOW) totalSentLOW += sent[1] else totalSentHIGH += sent[1];
    }
    return .{ totalSentLOW, totalSentHIGH };
}
// fn propagate(nodes: *ModuleMap, queue: *SingalQueue) !struct { usize, usize } {
//     var totalSentLOW: usize = 0;
//     var totalSentHIGH: usize = 0;
//     var sentMessage = true;
//     while (sentMessage) {
//         sentMessage = false;
//         for (queue.items) |*node| {
//             // std.debug.print("##          {s}\n", .{node.name});
//             const sent = try node.handleSignal(nodes);
//             if (sent[1] > 0) sentMessage = true;
//             if (sent[0] == .LOW) totalSentLOW += sent[1] else totalSentHIGH += sent[1];
//             // break;
//         }
//     }
//     return .{ totalSentLOW, totalSentHIGH };
// }
