const std = @import("std");

const Game = @import("../Game.zig");
const LevelUpdater = @import("../LevelUpdater.zig");

const Water = @This();

pub fn update(self: Water, x: i32, y: i32, game: *Game, level: *LevelUpdater) void {
    _ = self;
    var rnd = game.rnd;
    var below = level.getCell(x, y + 1);
    if (below == .Empty) {
        level.setCell(x, y, below);
        level.setCell(x, y + 1, .Water);
        return;
    }
    var first: i32 = -1;
    var second: i32 = 1;
    if (rnd.boolean()) {
        first = 1;
        second = -1;
    }
    var cellFirst = level.getCell(x + first, y + 1);
    if (cellFirst == .Empty) {
        level.setCell(x, y, cellFirst);
        level.setCell(x + first, y + 1, .Water);
        return;
    }
    var cellSecond = level.getCell(x + second, y + 1);
    if (cellSecond == .Empty) {
        level.setCell(x, y, cellSecond);
        level.setCell(x + second, y + 1, .Water);
        return;
    }
    cellFirst = level.getCell(x + first, y);
    if (cellFirst == .Empty or cellFirst == .Sand) {
        level.setCell(x, y, cellFirst);
        level.setCell(x + first, y, .Water);
        return;
    }
    cellSecond = level.getCell(x + second, y);
    if (cellSecond == .Empty or cellSecond == .Sand) {
        level.setCell(x, y, cellSecond);
        level.setCell(x + second, y, .Water);
        return;
    }
}