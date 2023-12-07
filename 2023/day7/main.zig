const std = @import("std");
const tokenize = std.mem.tokenize;
const input = @embedFile("input.txt");

const part = 2;

const Card = enum(u8) {
    two = 2,
    three = 3,
    four = 4,
    five = 5,
    six = 6,
    seven = 7,
    eight = 8,
    nine = 9,
    T = 10,
    J = if (part == 1) 11 else 1,
    Q = 12,
    K = 13,
    A = 14,
};

const Valid_hands = enum(u8) {
    High_card = 1,
    One_pair = 2,
    Two_pair = 3,
    Three_of_a_kind = 4,
    Full_house = 5,
    Four_of_a_kind = 6,
    Five_of_a_kind = 7,
};

const Hand = struct {
    c: [5]Card,
    h: Valid_hands = undefined,
    bid: usize = 0,

    pub fn new(cards: [5]Card, bid: usize) Hand {
        var ret = Hand{ .c = cards };
        ret.h = ret.find_valid_hands();
        ret.bid = bid;
        return ret;
    }

    fn find_valid_hands(self: *Hand) Valid_hands {
        var card_counts = [1]u8{0} ** 15;
        var jokers: u8 = 0;
        for (self.c) |c| {
            if (part == 1) {
                card_counts[@intFromEnum(c)] += 1;
            } else {
                if (c == Card.J) { //remove this if for part1
                    jokers += 1;
                } else {
                    card_counts[@intFromEnum(c)] += 1;
                }
            }
        }
        var most_common_card_idx: usize = 0;
        var max_occurence: usize = 0;
        for (card_counts, 0..) |c, i| {
            if (c > max_occurence) {
                max_occurence = c;
                most_common_card_idx = i;
            }
        }
        card_counts[most_common_card_idx] += jokers;

        var pair_count: u8 = 0;
        var tripplet_count: u8 = 0;
        for (card_counts) |c| {
            if (c == 5) return Valid_hands.Five_of_a_kind;
            if (c == 4) return Valid_hands.Four_of_a_kind;
            if (c == 3) tripplet_count += 1;
            if (c == 2) pair_count += 1;
        }
        if (tripplet_count == 1 and pair_count == 1) return Valid_hands.Full_house;
        if (tripplet_count == 1) return Valid_hands.Three_of_a_kind;
        if (pair_count == 2) return Valid_hands.Two_pair;
        if (pair_count == 1) return Valid_hands.One_pair;
        return Valid_hands.High_card;
    }
};
fn lower_hand(_: void, lhs: Hand, rhs: Hand) bool {
    if (lhs.h != rhs.h) return @intFromEnum(lhs.h) < @intFromEnum(rhs.h);

    for (0..5) |i| {
        if (lhs.c[i] != rhs.c[i]) return @intFromEnum(lhs.c[i]) < @intFromEnum(rhs.c[i]);
    }
    return true;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var hands = std.ArrayList(Hand).init(alloc);
    defer hands.deinit();

    var it = tokenize(u8, input, "\n");
    while (it.next()) |line| {
        var line_it = tokenize(u8, line, " ");
        const game_str = line_it.next().?;
        const bid_str = line_it.next().?;
        var cards = [1]Card{Card.two} ** 5;
        for (0..5) |idx| {
            const ca = game_str[idx .. idx + 1];
            switch (ca[0]) {
                '2'...'9' => {
                    cards[idx] = @enumFromInt(ca[0] - '0');
                },
                'T', 'J', 'Q', 'K', 'A' => {
                    cards[idx] = std.meta.stringToEnum(Card, ca).?;
                },
                else => {
                    return error.ParseErr_InvalidCharacter;
                },
            }
        }

        const bid: usize = try std.fmt.parseInt(usize, bid_str, 10);
        const new_hand = Hand.new(cards, bid);

        try hands.append(new_hand);
    }

    // for (hands.items) |h| {
    //     std.debug.print("Cards: {any} hand: {} bid: {}\n", .{ h.c, h.h, h.bid });
    // }

    var x = try hands.toOwnedSlice();
    defer alloc.free(x);
    std.mem.sortUnstable(Hand, x, {}, lower_hand);

    // std.debug.print("sorted: \n", .{});
    // for (x) |h| {
    //     std.debug.print("Cards: {any} hand: {} bid: {}\n", .{ h.c, h.h, h.bid });
    // }

    var total_winnings: usize = 0;
    for (x, 1..) |hand, rank| {
        total_winnings += hand.bid * rank;
    }

    std.debug.print("Part{}: total_winnings: {}\n", .{ part, total_winnings });
}
