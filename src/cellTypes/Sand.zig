const std = @import("std");

const Game = @import("../Game.zig");
const LevelUpdater = @import("../LevelUpdater.zig");
const Cell = @import("../Cell.zig");

const Sand = @This();

pub fn update(self: Cell, x: i32, y: i32, game: *Game, level: *LevelUpdater) void {
    var rnd = game.rnd;
    var below = level.getCell(x, y + 1);
    if (below.type == .Empty or below.type == .Water) {
        level.setCell(x, y, below);
        level.setCell(x, y + 1, self);
        return;
    }
    var first: i32 = -1;
    var second: i32 = 1;
    if (rnd.boolean()) {
        first = 1;
        second = -1;
    }
    var cellFirst = level.getCell(x + first, y + 1);
    if (cellFirst.type == .Empty) {
        level.setCell(x, y, cellFirst);
        level.setCell(x + first, y + 1, self);
        return;
    }
    var cellSecond = level.getCell(x + second, y + 1);
    if (cellSecond.type == .Empty) {
        level.setCell(x, y, cellSecond);
        level.setCell(x + second, y + 1, self);
        return;
    }
}
