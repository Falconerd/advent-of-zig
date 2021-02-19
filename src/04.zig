const std = @import("std");
const print = std.debug.print;

fn indexOf(query: []const u8, items: [7][]const u8) !u8 {
    for (items) |item, index| {
        if (std.mem.eql(u8, item, query)) {
            return @intCast(u8, index);
        }
    }
    return error.ItemNotFound;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var file = try std.fs.cwd().openFile("src/04_input.dat", std.fs.File.OpenFlags{ .read = true });
    defer file.close();

    var len = try file.getEndPos();
    var content = try file.reader().readAllAlloc(&gpa.allocator, len);

    var map = std.AutoHashMap(usize, []const u8).init(&gpa.allocator);
    defer map.deinit();

    var line_it = std.mem.split(content, "\n");
    var line_count: usize = 0;

    var line_list = std.ArrayList([]const u8).init(&gpa.allocator);
    defer line_list.deinit();

    var labels = [7][]const u8{ "ecl", "pid", "eyr", "hcl", "byr", "iyr", "hgt" };
    var rules: u8 = 0;
    var block_index: usize = 0;
    var valid_count: usize = 0;

    while (line_it.next()) |line| {
        if (line.len == 0) {
            if (rules == 127) {
                print("block {} success.\n", .{block_index});
                valid_count += 1;
            }
            block_index += 1;
            rules = 0;
        }
        var items_it = std.mem.split(line, " ");
        while (items_it.next()) |item| {
            var item_it = std.mem.split(item, ":");
            var index = indexOf(item_it.next().?, labels) catch continue;
            rules |= (@intCast(u8, 1) << @intCast(u3, index));
        }
    }

    print("vaild items: {}\n", .{valid_count});
}
