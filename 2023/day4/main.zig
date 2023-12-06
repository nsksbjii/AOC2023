const std = @import("std");
const input = @embedFile("input.txt");

const win_len = 10;
const have_len = 25;

const Card = struct {
    card_nr: usize,
    winning_numbers: [win_len]usize,
    have_numbers: [have_len]usize,
    copies: usize = 1,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var cards = std.ArrayList(Card).init(alloc);
    defer cards.deinit();

    var it = std.mem.tokenize(u8, input, "\n");
    while (it.next()) |line| {
        var card = std.mem.tokenize(u8, line, "|");
        var winning_part = card.next().?;
        var have_part = card.next().?;
        var winning_tok = std.mem.tokenize(u8, winning_part, ":");
        //skip Card 1;
        var card_nr_part = winning_tok.next().?;
        var card_nr = std.mem.tokenize(u8, card_nr_part, " ");
        _ = card_nr.next();
        const card_nr_int = try std.fmt.parseInt(usize, card_nr.next().?, 10);

        var winning_numbers = std.mem.tokenize(u8, winning_tok.next().?, " ");
        var current_card = Card{ .card_nr = card_nr_int, .winning_numbers = [1]usize{0} ** win_len, .have_numbers = [1]usize{0} ** have_len };
        var i: usize = 0;
        while (winning_numbers.next()) |w| : (i += 1) {
            current_card.winning_numbers[i] = try std.fmt.parseInt(usize, w, 10);
        }

        var have_numbers = std.mem.tokenize(u8, have_part, " ");

        i = 0;
        while (have_numbers.next()) |h| : (i += 1) {
            current_card.have_numbers[i] = try std.fmt.parseInt(usize, h, 10);
        }
        try cards.append(current_card);
    }

    //part1

    {
        var sum: usize = 0;
        for (cards.items) |card| {
            var card_val: usize = 0;
            for (card.have_numbers) |hn| {
                for (card.winning_numbers) |wn| {
                    if (hn == wn) {
                        if (card_val == 0) {
                            card_val = 1;
                        } else {
                            card_val *= 2;
                        }
                    }
                }
            }
            sum += card_val;
        }

        std.debug.print("part1: {}\n", .{sum});
    }

    //part 2
    {
        for (cards.items) |card| {
            var matches: usize = 0;
            for (card.have_numbers) |hn| {
                for (card.winning_numbers) |wn| {
                    if (hn == wn) {
                        matches += 1;
                    }
                }
            }
            var i = card.card_nr;
            while (i < card.card_nr + matches and i < cards.items.len) : (i += 1) {
                cards.items[i].copies += card.copies;
            }
        }
        var sum: usize = 0;
        for (cards.items) |c| {
            sum += c.copies;
        }
        std.debug.print("sum2: {}\n", .{sum});
    }
}
