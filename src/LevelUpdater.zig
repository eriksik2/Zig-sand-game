const std = @import("std");
const Level = @import("Level.zig");
const Cell = @import("Cell.zig");

const LevelUpdater = @This();

level: *Level,
didWrite: []bool,

pub fn init(allocator: *std.mem.Allocator, level: *Level) !*LevelUpdater {
    var updater = try allocator.create(LevelUpdater);
    errdefer allocator.destroy(updater);
    updater.level = level;

    updater.didWrite = try allocator.alloc(bool, updater.level.width * updater.level.height);
    @memset(updater.didWrite, false);

    return updater;
}

pub fn deinit(self: *LevelUpdater, allocator: *std.mem.Allocator) void {
    allocator.free(self.didWrite);
    allocator.destroy(self);
}

pub fn getDidWrite(self: *const LevelUpdater, x: i32, y: i32) bool {
    if (x < 0 or y < 0 or x >= self.level.width or y >= self.level.height) return false;
    return self.didWrite[@intCast(u32, x) + @intCast(u32, y) * self.level.width];
}

pub fn getTemp(self: *const LevelUpdater, x: i32, y: i32) f32 {
    return self.level.getTemp(x, y);
}

pub fn setTemp(self: *LevelUpdater, x: i32, y: i32, temp: f32) void {
    self.level.setTemp(x, y, temp);
    self.didWrite[@intCast(u32, x) + @intCast(u32, y) * self.level.width] = true;
}

pub fn getCell(self: *const LevelUpdater, x: i32, y: i32) Cell {
    return self.level.getCell(x, y);
}

pub fn setCell(self: *LevelUpdater, x: i32, y: i32, cell: Cell) void {
    self.level.setCell(x, y, cell);
    self.didWrite[@intCast(u32, x) + @intCast(u32, y) * self.level.width] = true;
}

pub fn setCellType(self: *LevelUpdater, x: i32, y: i32, cell: Cell.CellType) void {
    self.level.setCellType(x, y, cell);
    self.didWrite[@intCast(u32, x) + @intCast(u32, y) * self.level.width] = true;
}
