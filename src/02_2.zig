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
        const q = query_it.next().?[0];

        var range_it = std.mem.split(range.?, "-");
        const p1 = std.fmt.parseInt(u32, range_it.next().?, 10) catch break;
        const p2 = std.fmt.parseInt(u32, range_it.next().?, 10) catch break;

        var count: u32 = 0;

        if (value) |v| {
            if (v[p1-1] == q) {
                count += 1;
            }

            if (v[p2-1] == q) {
                count += 1;
            }

            if (count == 1)
                valid_count += 1;
        }
    }

    warn("Number of valid passwords: {}\n", .{valid_count});
 }
