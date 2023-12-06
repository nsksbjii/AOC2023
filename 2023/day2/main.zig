const std = @import("std");
const input = @embedFile("input.txt");

const Colors = enum {
    red,
    green,
    blue,
};
const Set = struct {
    red: usize,
    green: usize,
    blue: usize,
};
const Game = struct {
    id: usize,
    sets: std.ArrayList(Set),

    pub fn init(game_id: usize, alloc: std.mem.Allocator) Game {
        return Game{ .id = game_id, .sets = std.ArrayList(Set).init(alloc) };
    }

    pub fn add_set(self: *Game, r: usize, g: usize, b: usize) !void {
        self.sets.append(Set{ .red = r, .green = g, .blue = b }) catch |err| return err;
    }

    pub fn is_possible(self: *const Game, r: usize, g: usize, b: usize) bool {
        for (self.sets.items) |set| {
            if (set.red > r or set.green > g or set.blue > b) return false;
        }
        return true;
    }
    pub fn destroy(self: *const Game) void {
        self.sets.deinit();
    }

    pub fn power(self: *const Game) usize {
        var max_red: usize = 0;
        var max_green: usize = 0;
        var max_blue: usize = 0;

        for (self.sets.items) |set| {
            if (max_red < set.red) max_red = set.red;
            if (max_green < set.green) max_green = set.green;
            if (max_blue < set.blue) max_blue = set.blue;
        }

        return max_red * max_green * max_blue;
    }

    pub fn print(self: *const Game) void {
        const id = self.id;
        std.debug.print("game_id {} :", .{id});

        for (self.sets.items) |set| {
            std.debug.print("{any}", .{set});
        }
    }
};
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    var games = std.ArrayList(Game).init(alloc);
    defer {
        for (games.items) |g| {
            g.destroy();
        }
        games.deinit();
    }

    // defer for (games.items) |g| g.destroy();
    var lines = std.mem.tokenize(u8, input, "\n");

    while (lines.next()) |line| {

        //seperate game 1 : 3 blue 5 red 3 green by
        //
        var split_colon = std.mem.tokenize(u8, line, ":");
        const game_id = blk: {
            var game_part = std.mem.tokenize(u8, split_colon.next().?, " ");
            _ = game_part.next();
            break :blk game_part.next();
        };

        var current_game = Game.init(try std.fmt.parseInt(usize, game_id.?, 10), alloc);

        var sets = std.mem.tokenize(u8, split_colon.next().?, ";");
        while (sets.next()) |set| {
            var set_colors = std.mem.tokenize(u8, set, ",");
            var red: usize = 0;
            var green: usize = 0;
            var blue: usize = 0;

            while (set_colors.next()) |value_color| {
                var value_color_tok = std.mem.tokenize(u8, value_color, " ");
                const value = value_color_tok.next();
                const color = value_color_tok.next();

                red += if (std.mem.eql(u8, color.?, @tagName(Colors.red))) try std.fmt.parseInt(usize, value.?, 10) else 0;
                green += if (std.mem.eql(u8, color.?, @tagName(Colors.green))) try std.fmt.parseInt(usize, value.?, 10) else 0;
                blue += if (std.mem.eql(u8, color.?, @tagName(Colors.blue))) try std.fmt.parseInt(usize, value.?, 10) else 0;
            }
            try current_game.add_set(red, green, blue);
        }
        // current_game.print();
        try games.append(current_game);
    }

    var part1: usize = 0;
    var part2: usize = 0;
    for (games.items) |game| {
        if (game.is_possible(12, 13, 14)) part1 += game.id;
        part2 += game.power();
    }

    std.debug.print("part1: {}\n", .{part1});
    std.debug.print("part2: {}\n", .{part2});
}
