const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var file = try std.fs.cwd().openFile("src/03_input.dat", std.fs.File.OpenFlags{ .read = true });
    defer file.close();

    var len = try file.getEndPos();
    var content = try file.reader().readAllAlloc(&gpa.allocator, len);

    var line_it = std.mem.split(content, "\n");

    var index: usize = 0;
    var hit_trees: usize = 0;

    while (line_it.next()) |item| {
        if (item.len == 0) continue;
        var line_index: usize = index % item.len;
        index += item.len + 3;
        if (item[line_index] == '#') {
            hit_trees += 1;
        }
    }

    print("You hit {} trees\n", .{hit_trees});
}
