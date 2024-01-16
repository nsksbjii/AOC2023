const std = @import("std");
const input = @embedFile("input.txt");

const keys = enum {
    ls,
    cd,
    dir,
    f,
};
const File = struct {
    name: []const u8,
    size: usize,
};

const Dir = struct {
    name: []const u8,
    files: std.ArrayList(File),
    dirs: std.ArrayList(Dir),
    up: ?*Dir = null,
    size: usize = undefined,

    pub fn new_dir(alloc: std.mem.Allocator, name: []const u8, up: ?*Dir) !Dir {
        return Dir{ .name = name, .files = std.ArrayList(File).init(alloc), .dirs = std.ArrayList(Dir).init(alloc), .up = up };
    }
    pub fn add_file(self: *Dir, f: File) !void {
        try self.files.append(f);
    }

    pub fn add_dir(self: *Dir, d: Dir) !void {
        try self.dirs.append(d);
    }
    pub fn destroy(self: *Dir) void {
        self.files.deinit();

        for (self.dirs.items) |*d| {
            d.destroy();
        }
        self.dirs.deinit();
    }
    pub fn sizes(self: *Dir) void {
        self.*.size = self.get_size();
        for (self.dirs.items) |*d| {
            d.sizes();
        }
    }
    pub fn get_size(self: *Dir) usize {
        var sum: usize = 0;
        for (self.files.items) |f| {
            sum += f.size;
        }
        for (self.dirs.items) |*d| {
            sum += d.get_size();
        }
        return sum;
    }

    pub fn sizes_part1(self: *Dir) usize {
        var sum: usize = if (self.size <= 100_000) self.size else 0;
        for (self.dirs.items) |*d| {
            sum += d.sizes_part1();
        }
        const n = self.up orelse self;
        _ = n;
        // std.debug.print("{}  {s} {s}\n\n", .{ self.size, self.name[0..], n.name[0..] });
        return sum;
    }

    pub fn p2(self: *Dir, arr: *std.ArrayList(usize), target: usize) !void {
        if (self.size > target) try arr.append(self.size);
        for (self.dirs.items) |*d| {
            try d.p2(arr, target);
        }
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var root = try Dir.new_dir(alloc, "/", null);
    defer root.destroy();
    var working_dir: *Dir = &root;
    var it = std.mem.tokenize(u8, input, "\n$ ");
    var i: usize = 0;
    while (it.next()) |tok| : (i += 1) {
        // std.debug.print("i{}\n", .{i});
        const key = std.meta.stringToEnum(keys, tok) orelse keys.f;
        // std.debug.print("{any}", .{key});
        switch (key) {
            keys.cd => {
                const name = it.next().?;
                // std.debug.print("case cd {s}\n", .{name});
                if (std.mem.eql(u8, "/", name)) continue;
                if (std.mem.eql(u8, "..", name)) {
                    working_dir = working_dir.up.?;
                    continue;
                }
                for (working_dir.dirs.items) |*d| {
                    if (std.mem.eql(u8, d.*.name, name)) {
                        working_dir = d;
                        break;
                    }
                }
            },
            keys.ls => {
                // std.debug.print("case ls", .{});
                continue;
            },
            keys.dir => {
                // std.debug.print("case dir", .{});
                var new_dir = try Dir.new_dir(alloc, it.next().?, working_dir);
                // std.debug.print("added {any}", .{new_dir});
                try working_dir.add_dir(new_dir);
            },
            else => {
                // std.debug.print("case else {s}\n", .{working_dir.name});
                var size = std.fmt.parseInt(usize, tok, 10) catch return error.ParseInt;
                var file_name = it.next().?;
                // std.debug.print("file:name: {any}", .{size});
                var new_file = File{ .name = file_name, .size = size };
                // std.debug.print("{any}", .{working_dir});
                try working_dir.add_file(new_file);
            },
        }
    }

    root.sizes();
    // std.debug.print("{any}\n\n", .{root});

    // std.debug.print("working_dir {any}\n\n", .{working_dir.files.items});
    // std.debug.print("working_dirsize {any}\n", .{working_dir.get_size()});
    std.debug.print("part1 {}\n", .{root.sizes_part1()});

    const storage: usize = 70_000_000;
    const free = storage - root.size;
    const missing = 30_000_000 - free;

    var possible = std.ArrayList(usize).init(alloc);
    defer possible.deinit();

    try root.p2(&possible, missing);

    // std.debug.print("{any}\n", .{possible.items});

    var min: usize = 0xffffffffffffffff;
    for (possible.items) |ix| {
        if (min > ix) min = ix;
    }

    std.debug.print("{}\n", .{min});
}
