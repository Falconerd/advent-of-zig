const std = @import("std");
const fs = std.fs;
const warn = std.debug.warn;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var file = try fs.cwd().openFile("src/01_input.dat", fs.File.OpenFlags{ .read = true });
    defer file.close();

    var len = try file.getEndPos();
    var content = try file.reader().readAllAlloc(&gpa.allocator, len);

    var spliterator = std.mem.split(content, "\n");

    var next = spliterator.next();
    var numbers = std.ArrayList(u32).init(std.heap.page_allocator);
    defer numbers.deinit();

    while (next) |item| {
        const number = std.fmt.parseInt(u32, item, 10) catch break;
        try numbers.append(number);
        next = spliterator.next();
    }

    loop: for (numbers.items) |p| {
        for (numbers.items) |q| {
            for (numbers.items) |r| {
                if (p + q + r == 2020) {
                    warn("{} * {} * {} = {}\n", .{p, q, r, p * q * r});
                    break :loop;
                }
            }
        }
    }
 }
