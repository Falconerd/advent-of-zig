const std = @import("std");
const fs = std.fs;
const warn = std.debug.warn;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var file = try fs.cwd().openFile("src/02_input.dat", fs.File.OpenFlags{ .read = true });
    defer file.close();

    var len = try file.getEndPos();
    var content = try file.reader().readAllAlloc(&gpa.allocator, len);

    var spliterator = std.mem.split(content, "\n");

    var valid_count: u32 = 0;

    while (spliterator.next()) |item| {
        var it = std.mem.split(item, " ");
        const range = it.next();
        const query = it.next();
        const value = it.next();

        if (range == null or query == null or value == null) {
            break;
        }

        var query_it = std.mem.split(query.?, ":");
        const q = query_it.next().?;

        var range_it = std.mem.split(range.?, "-");
        const min = std.fmt.parseInt(u32, range_it.next().?, 10) catch break;
        const max = std.fmt.parseInt(u32, range_it.next().?, 10) catch break;
        var count = std.mem.count(u8, value.?, q);

        if (count >= min and count <= max) {
            valid_count += 1;
        }
    }

    warn("Number of valid passwords: {}\n", .{valid_count});
 }
