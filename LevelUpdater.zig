const std = @import("std");
const Level = @import("Level.zig");
const Cell = @import("cell.zig").Cell;

const LevelUpdater = @This();

readLevel: *const Level,
writeLevel: *Level,
didWrite: []bool,

pub fn init(allocator: *std.mem.Allocator, level: *Level) !*LevelUpdater {
    var updater = try allocator.create(LevelUpdater);
    errdefer allocator.destroy(updater);
    updater.readLevel = level;

    updater.writeLevel = try level.clone(allocator);
    errdefer updater.writeLevel.deinit(allocator);

    updater.didWrite = try allocator.alloc(bool, updater.readLevel.width * updater.readLevel.height);
    @memset(updater.didWrite, false);

    return updater;
}

pub fn deinit(self: *LevelUpdater, allocator: *std.mem.Allocator) void {
    allocator.free(self.didWrite);
    self.writeLevel.deinit(allocator);
    allocator.destroy(self);
}

pub fn getDidWrite(self: *const LevelUpdater, x: i32, y: i32) bool {
    if (x < 0 or y < 0 or x >= self.readLevel.width or y >= self.readLevel.height) return false;
    return self.didWrite[@intCast(u32, x) + @intCast(u32, y) * self.readLevel.width];
}

pub fn getCell(self: *const LevelUpdater, x: i32, y: i32) Cell {
    return self.readLevel.getCell(x, y);
}

pub fn setCell(self: *LevelUpdater, x: i32, y: i32, cell: Cell) void {
    self.writeLevel.setCell(x, y, cell);
}

pub fn commit(self: *LevelUpdater) void {
    std.debug.assert(self.readLevel.width == self.writeLevel.width and
        self.readLevel.height == self.writeLevel.height);
    @memcpy(self.readLevel.cells.items, self.writeLevel.cells.items);
}
