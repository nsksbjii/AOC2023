const std = @import("std");
const input = @embedFile("input.txt");
const tokenize = std.mem.tokenize;
const split = std.mem.split;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var it = split(u8, input, "\n\n");

    var seeds = std.ArrayList(usize).init(alloc);
    var seed_to_soil_map = std.ArrayList([3]usize).init(alloc);
    var soil_to_fertilizer_map = std.ArrayList([3]usize).init(alloc);
    var fertilizer_to_water_map = std.ArrayList([3]usize).init(alloc);
    var water_to_light_map = std.ArrayList([3]usize).init(alloc);
    var light_to_tmeperature_map = std.ArrayList([3]usize).init(alloc);
    var temperature_to_humidity_map = std.ArrayList([3]usize).init(alloc);
    var humidity_to_location_map = std.ArrayList([3]usize).init(alloc);
    defer {
        seeds.deinit();
        seed_to_soil_map.deinit();
        soil_to_fertilizer_map.deinit();
        fertilizer_to_water_map.deinit();
        water_to_light_map.deinit();
        light_to_tmeperature_map.deinit();
        temperature_to_humidity_map.deinit();
        humidity_to_location_map.deinit();
    }

    var seeds_it = it.next();
    var seed_to_soil_it = it.next();
    var soil_to_fertilizer_it = it.next();
    var fertilizer_to_water_it = it.next();
    var water_to_light_it = it.next();
    var light_to_tmeperature_it = it.next();
    var temperature_to_humidity_it = it.next();
    var humidity_to_location_it = it.next();

    { //get seeds
        var seeds_tok = tokenize(u8, seeds_it.?, ":");
        _ = seeds_tok.next();
        var seed_vals = tokenize(u8, seeds_tok.next().?, " ");

        var i: usize = 0;
        while (seed_vals.next()) |s| : (i += 1) {
            // std.debug.print("s: {s}", .{s});

            try seeds.append(try std.fmt.parseInt(usize, s, 10));
        }

        // std.debug.print("seeds: {any}\n", .{seeds.items});
    }

    { //get seed_to_soil
        var seed_to_soil_tok = tokenize(u8, seed_to_soil_it.?, ":");
        _ = seed_to_soil_tok.next();
        var seed_to_soil_ranges = tokenize(u8, seed_to_soil_tok.next().?, "\n");
        while (seed_to_soil_ranges.next()) |r| {
            var range = tokenize(u8, r, " ");
            var j: usize = 0;
            var current_range = [3]usize{ 0, 0, 0 };
            while (range.next()) |n| : (j += 1) {
                current_range[j] = try std.fmt.parseInt(usize, n, 10);
            }
            try seed_to_soil_map.append(current_range);
        }

        // std.debug.print("seed_to_soil_map: {any}\n", .{seed_to_soil_map.items});
    }

    { //get soil_to_fertilizer

        var soil_to_fertilizer_tok = tokenize(u8, soil_to_fertilizer_it.?, ":");
        _ = soil_to_fertilizer_tok.next();
        var soil_to_fertilizer_ranges = tokenize(u8, soil_to_fertilizer_tok.next().?, "\n");
        while (soil_to_fertilizer_ranges.next()) |r| {
            var range = tokenize(u8, r, " ");
            var j: usize = 0;
            var current_range = [3]usize{ 0, 0, 0 };
            while (range.next()) |n| : (j += 1) {
                current_range[j] = try std.fmt.parseInt(usize, n, 10);
            }
            try soil_to_fertilizer_map.append(current_range);
        }

        // std.debug.print("soil_to_fertilizer_map: {any}\n", .{soil_to_fertilizer_map.items});
    }

    { //get fertilizer_to_water

        var fertilizer_to_water_tok = tokenize(u8, fertilizer_to_water_it.?, ":");
        _ = fertilizer_to_water_tok.next();
        var fertilizer_to_water_ranges = tokenize(u8, fertilizer_to_water_tok.next().?, "\n");
        while (fertilizer_to_water_ranges.next()) |r| {
            var range = tokenize(u8, r, " ");
            var j: usize = 0;
            var current_range = [3]usize{ 0, 0, 0 };
            while (range.next()) |n| : (j += 1) {
                current_range[j] = try std.fmt.parseInt(usize, n, 10);
            }
            try fertilizer_to_water_map.append(current_range);
        }

        // std.debug.print("fertilizer_to_water_map: {any}\n", .{fertilizer_to_water_map.items});
    }

    { // get water_to_light

        var water_to_light_tok = tokenize(u8, water_to_light_it.?, ":");
        _ = water_to_light_tok.next();
        var water_to_light_ranges = tokenize(u8, water_to_light_tok.next().?, "\n");
        while (water_to_light_ranges.next()) |r| {
            var range = tokenize(u8, r, " ");
            var j: usize = 0;
            var current_range = [3]usize{ 0, 0, 0 };
            while (range.next()) |n| : (j += 1) {
                current_range[j] = try std.fmt.parseInt(usize, n, 10);
            }
            try water_to_light_map.append(current_range);
        }

        // std.debug.print("water_to_light_map: {any}\n", .{water_to_light_map.items});
    }

    { //get light_to_tmeperature

        var light_to_temperature_tok = tokenize(u8, light_to_tmeperature_it.?, ":");
        _ = light_to_temperature_tok.next();
        var light_to_temperatuer_ranges = tokenize(u8, light_to_temperature_tok.next().?, "\n");
        while (light_to_temperatuer_ranges.next()) |r| {
            var range = tokenize(u8, r, " ");
            var j: usize = 0;
            var current_range = [3]usize{ 0, 0, 0 };
            while (range.next()) |n| : (j += 1) {
                current_range[j] = try std.fmt.parseInt(usize, n, 10);
            }
            try light_to_tmeperature_map.append(current_range);
        }

        // std.debug.print("light_to_tmeperature_map: {any}\n", .{light_to_tmeperature_map.items});
    }

    { // get temperature_to_humidity

        var temperature_to_humidity_yok = tokenize(u8, temperature_to_humidity_it.?, ":");
        _ = temperature_to_humidity_yok.next();
        var light_temperature_to_humidity_ranges = tokenize(u8, temperature_to_humidity_yok.next().?, "\n");
        while (light_temperature_to_humidity_ranges.next()) |r| {
            var range = tokenize(u8, r, " ");
            var j: usize = 0;
            var current_range = [3]usize{ 0, 0, 0 };
            while (range.next()) |n| : (j += 1) {
                current_range[j] = try std.fmt.parseInt(usize, n, 10);
            }
            try temperature_to_humidity_map.append(current_range);
        }

        // std.debug.print("temperature_to_humidity_map: {any}\n", .{temperature_to_humidity_map.items});
    }

    { // get humidity_to_location

        var humidity_to_location_tok = tokenize(u8, humidity_to_location_it.?, ":");
        _ = humidity_to_location_tok.next();
        var lighhumidity_to_location_ranfes = tokenize(u8, humidity_to_location_tok.next().?, "\n");
        while (lighhumidity_to_location_ranfes.next()) |r| {
            var range = tokenize(u8, r, " ");
            var j: usize = 0;
            var current_range = [3]usize{ 0, 0, 0 };
            while (range.next()) |n| : (j += 1) {
                current_range[j] = try std.fmt.parseInt(usize, n, 10);
            }
            try humidity_to_location_map.append(current_range);
        }

        // std.debug.print("humidity_to_location_map: {any}\n", .{humidity_to_location_map.items});
    }

    //part
    //
    var seeed_ranges = std.ArrayList(@Vector(2, usize)).init(alloc);
    defer seeed_ranges.deinit();

    var maps = std.ArrayList(std.ArrayList([3]usize)).init(alloc);
    defer maps.deinit();
    try maps.append(seed_to_soil_map);
    try maps.append(soil_to_fertilizer_map);
    try maps.append(fertilizer_to_water_map);
    try maps.append(water_to_light_map);
    try maps.append(light_to_tmeperature_map);
    try maps.append(temperature_to_humidity_map);
    try maps.append(humidity_to_location_map);

    var i: usize = 0;
    while (i < seeds.items.len - 1) : (i += 2) {
        try seeed_ranges.append(@Vector(2, usize){ seeds.items[i], seeds.items[i] + seeds.items[i + 1] });
    }

    { // std.debug.print("seed_ranges: {any}\n", .{seeed_ranges.items});
        var locations = std.ArrayList(@Vector(2, usize)).init(alloc);
        defer locations.deinit();
        for (maps.items) |map| {
            while (seeed_ranges.items.len > 0) {
                var current = seeed_ranges.pop();
                for (map.items) |m| {
                    const os = @max(current[0], m[1]);
                    const oe = @min(current[1], m[1] + m[2]);
                    if (os < oe) {
                        try locations.append(@Vector(2, usize){ os - m[1] + m[0], oe - m[1] + m[0] });
                        if (os > current[0]) {
                            try seeed_ranges.append(@Vector(2, usize){ current[0], os });
                        }
                        if (current[1] > oe) {
                            try seeed_ranges.append(@Vector(2, usize){ oe, current[1] });
                        }
                        break;
                    }
                } else {
                    try locations.append(current);
                }
            }
            try seeed_ranges.appendSlice(locations.items);
            locations.clearRetainingCapacity();
        }

        // std.debug.print("locations: {any}\n", .{seeed_ranges.items});

        var min: usize = 0xffffffffffffffff;
        for (seeed_ranges.items) |c| {
            const min_vec = @reduce(.Min, c);
            if (min > min_vec) min = min_vec;
        }
        std.debug.print("part 2: {}\n", .{min});
    }
    {
        var locations = std.ArrayList(usize).init(alloc);
        defer locations.deinit();
        for (seeds.items) |*current| {
            for (maps.items) |map| {
                for (map.items) |m| {
                    if (current.* >= m[1] and current.* <= m[1] + m[2]) {
                        current.* = m[0] + (current.* - m[1]);
                        break;
                    }
                }
            }
        }

        // std.debug.print("locations: {any}\n", .{seeed_ranges.items});
        var min: usize = 0xffffffffffffffff;

        for (seeds.items) |c| {
            if (min > c) min = c;
        }
        std.debug.print("part 1: {}\n", .{min});
    }
    // std.debug.print("part2: {}\n", .{min});

}
