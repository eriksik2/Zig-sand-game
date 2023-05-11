const std = @import("std");
const Cell = @import("cell.zig").Cell;

const Level = @This();

width: u32,
height: u32,
cells: std.ArrayList(Cell),

pub fn init(allocator: *std.mem.Allocator, width: u32, height: u32) !*Level {
    var self: *Level = try allocator.create(Level);
    errdefer allocator.destroy(self);
    self.* = undefined;
    self.width = width;
    self.height = height;

    self.cells = std.ArrayList(Cell).init(allocator.*);
    errdefer self.cells.deinit();

    try self.cells.resize(self.width * self.height);
    @memset(self.cells.items, .Empty);
    return self;
}

pub fn deinit(self: *Level, allocator: *std.mem.Allocator) void {
    self.cells.deinit();
    allocator.destroy(self);
}

pub fn clone(self: *Level, allocator: *std.mem.Allocator) !*Level {
    var cl: *Level = try Level.init(allocator, self.width, self.height);
    @memcpy(cl.cells.items, self.cells.items);
    return cl;
}

fn getIndex(self: *const Level, x: u32, y: u32) u64 {
    std.debug.assert(x < self.width);
    std.debug.assert(y < self.height);
    return x + y * self.width;
}

fn getPosition(self: *const Level, index: u64) struct { x: u32, y: u32 } {
    std.debug.assert(index < self.width * self.height);
    return .{
        .x = index % self.width,
        .y = index / self.width,
    };
}

pub fn getCell(self: *const Level, x: i32, y: i32) Cell {
    if (x < 0 or y < 0 or x >= self.width or y >= self.height) {
        return Cell.Wall;
    }
    return self.cells.items[self.getIndex(@intCast(u32, x), @intCast(u32, y))];
}

pub fn setCell(self: *Level, x: i32, y: i32, cell: Cell) void {
    if (x < 0 or y < 0 or x >= self.width or y >= self.height) {
        unreachable;
    }
    self.cells.items[self.getIndex(@intCast(u32, x), @intCast(u32, y))] = cell;
}
