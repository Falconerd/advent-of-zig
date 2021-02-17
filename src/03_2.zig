const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var file = try std.fs.cwd().openFile("src/03_input.dat", std.fs.File.OpenFlags{ .read = true });
    defer file.close();

    var len = try file.getEndPos();
    var content = try file.reader().readAllAlloc(&gpa.allocator, len);
    var map = std.AutoHashMap(usize, []const u8).init(&gpa.allocator);
    defer map.deinit();

    var line_it = std.mem.split(content, "\n");
    var line_count: usize = 0;

    while (line_it.next()) |line| {
        if (line.len == 0) break;
        try map.put(line_count, line);
        line_count += 1;
    }

    var offsets_h = [5]usize{1, 3, 5, 7, 1};
    var offsets_v = [5]usize{1, 1, 1, 1, 2};
    var hit_trees = [5]usize{0, 0, 0, 0, 0};
    var col = [5]usize{0, 0, 0, 0, 0};
    var row = [5]usize{0, 0, 0, 0, 0};

    var current: usize = 0;

    while (current < line_count - 1) {
        for (offsets_h) |offset_h, index| {
            var offset_v = offsets_v[index];
            row[index] += offset_v;
            if (row[index] < line_count) {
                var line = map.get(row[index]).?;
                col[index] += offset_h;
                if (col[index] >= line.len) {
                    col[index] -= line.len;
                }
                if (line[col[index]] == '#') {
                    hit_trees[index] += 1;
                }
            }
        }

        current += 1;
    }

    var total_hit_trees: usize = hit_trees[0] * hit_trees[1] * hit_trees[2] * hit_trees[3] * hit_trees[4];
    print("You hit {} {} {} {} {} {} trees\n", .{hit_trees[0], hit_trees[1], hit_trees[2], hit_trees[3], hit_trees[4], total_hit_trees});
}

