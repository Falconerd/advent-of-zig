const std = @import("std");
const print = std.debug.print;

const COLORS = [8][]const u8{ "amb", "blu", "brn", "gry", "grn", "hzl", "oth", "oth" };
const LABELS = [8][]const u8{ "ecl", "pid", "eyr", "hcl", "byr", "iyr", "hgt", "cid" };

fn indexOf(query: []const u8, items: [8][]const u8) !u8 {
    for (items) |item, index| {
        if (std.mem.eql(u8, item, query)) {
            return @intCast(u8, index);
        }
    }
    return error.ItemNotFound;
}

fn checkLength(value: []const u8, length: u32) !bool {
    if (value.len != length) return error.WrongLength;
    return true;
}

fn checkRange(value: []const u8, min: u32, max: u32) !bool {
    var number = try std.fmt.parseInt(u32, value, 10);
    if (number < min or number > max) return error.OutOfRange;
    return true;
}

fn checkIsHex(value: u8) !bool {
    if (value >= 'a' and value <= 'f') return true;
    if (value >= 'A' and value <= 'F') return true;
    if (value >= '0' and value <= '9') return true;
    return error.OutOfRange;
}

fn validateField(field: []const u8, value: []const u8) !bool {
    if (std.mem.eql(u8, field, "byr")) {
        // four digits; at least 1920 and at most 2002
        var length = checkLength(value, 4) catch |e| return e;
        var range = checkRange(value, 1920, 2002) catch |e| return e;
        return true;
    }
    if (std.mem.eql(u8, field, "iyr")) {
        // four digits; at least 2010 and at most 2020
        var length = checkLength(value, 4) catch |e| return e;
        var range = checkRange(value, 2010, 2020) catch |e| return e;
        return true;
    }
    if (std.mem.eql(u8, field, "eyr")) {
        // four digits; at least 2020 and at most 2030
        var length = checkLength(value, 4) catch |e| return e;
        var range = checkRange(value, 2020, 2030) catch |e| return e;
        return true;
    }
    if (std.mem.eql(u8, field, "hgt")) {
        // a number followed by either cm or in
        // if cm, the number must be at least 150 and at most 193
        // if in, the number must be at least 59 and at most 76
        if (value[value.len - 1] == 'm' and value[value.len - 2] == 'c') {
            var it = std.mem.split(value, "cm");
            if (it.next()) |number| {
                var range = checkRange(number, 150, 193) catch |e| return e;
                return true;
            }
            return error.HeightNotFound;
        }
        if (value[value.len - 1] == 'n' and value[value.len - 2] == 'i') {
            var it = std.mem.split(value, "in");
            if (it.next()) |number| {
                var range = checkRange(number, 59, 76) catch |e| return e;
                return true;
            }
            return error.HeightNotFound;
        }
        return error.InvalidHeightType;
    }
    if (std.mem.eql(u8, field, "hcl")) {
        // a # followed by exactly 6 characters 0-9 or a-f
        if (value[0] != '#') return error.HexNoHash;
        var it = std.mem.split(value, "#");
        var hex = it.next();
        if (hex) |h| {
            for (h) |char| {
                var isHex = checkIsHex(char) catch |e| return e;
            }
        }
        return true;
    }
    if (std.mem.eql(u8, field, "ecl")) {
        // exactly one of 'amb', 'blu', 'brn', 'gry', 'grn', 'hzl', 'oth'
        var index = indexOf(value, COLORS) catch return error.InvalidEyeColor;
        return true;
    }
    if (std.mem.eql(u8, field, "pid")) {
        // a nine digit number, including leading zeroes
        var length = checkLength(value, 9) catch |e| return e;
        for (value) |char| {
            if (char < '0' or char > '9') return error.InvalidNumberInPID;
        }
        return true;
    }
    if (std.mem.eql(u8, field, "cid")) return true;
    return error.UncaughtValidationError;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var file = try std.fs.cwd().openFile("src/04_input.dat", std.fs.File.OpenFlags{ .read = true });
    defer file.close();

    var len = try file.getEndPos();
    var content = try file.reader().readAllAlloc(&gpa.allocator, len);

    var people_it = std.mem.split(content, "\n\n");
    var valid_count: u32 = 0;

    validtor: while (people_it.next()) |person| {
        var p = try gpa.allocator.alloc(u8, person.len);
        _ = std.mem.replace(u8, person, "\n", " ", p);
        var items_it = std.mem.split(p, " ");
        var flags: u8 = 0;
        while (items_it.next()) |item| {
            var item_it = std.mem.split(item, ":");
            var field = item_it.next() orelse continue :validtor;
            var value = item_it.next() orelse continue :validtor;
            var index = indexOf(field, LABELS) catch continue :validtor;
            _ = validateField(field, value) catch continue :validtor;
            flags |= (@intCast(u8, 1) << @intCast(u3, index));
        }
        if (flags == 127 or flags == 255)
            valid_count += 1;
    }

    print("vaild items: {}\n", .{valid_count});
}
